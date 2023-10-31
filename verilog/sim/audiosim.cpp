//
// VerilogBoy simulator
// Copyright 2022 Wenting Zhang
//
// audiosim.cpp: Capture PDM output and pass through a filter then save to wave
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>
#include <vector>
#include "cic.h"
#include "audiosim.h"
#include "waveheader.h"

AUDIOSIM::AUDIOSIM(void) {
    initializeCicFilterStruct(3, DECIMATION_M, &filter_left);
    initializeCicFilterStruct(3, DECIMATION_M, &filter_right);
    pcm.clear();
    bit_counter = 0;
    byte_counter = 0;
    bypass_counter = 0;
}

AUDIOSIM::~AUDIOSIM(void) {

}

void AUDIOSIM::save(char *fname) {
    printf("Max: %d, min: %d\n", max, min);
    save_wav(fname, pcm);
    save_wav("bypass.wav", byp);
}

void AUDIOSIM::save_wav(char *fname, std::vector<int16_t> &pcm) {
    uint8_t header[44];
    waveheader(header, 48000, 16, pcm.size() / 2);
    FILE *fp;
    fp = fopen(fname, "wb+");
    fwrite(header, 44, 1, fp);
    fwrite(&pcm[0], pcm.size() * 2, 1, fp);
    fclose(fp);
    printf("Audio save to %s\n", fname);
}

void AUDIOSIM::apply(uint8_t left, uint8_t right) {
    byte_left |= left << 7;
    byte_right |= right << 7;
    bit_counter++;
    if (bit_counter < 8) {
        byte_left >>= 1;
        byte_right >>= 1;
    }
    else {
        bit_counter = 0;
        pdm_buffer_left[byte_counter] = byte_left;
        pdm_buffer_right[byte_counter] = byte_right;
        byte_counter++;
        if (byte_counter == PDM_SAMPLE_SIZE * DECIMATION_M / 8) {
            byte_counter = 0;
            executeCicFilter(pdm_buffer_left, PDM_SAMPLE_SIZE * DECIMATION_M,
                    pcm_buffer_left, &filter_left);
            executeCicFilter(pdm_buffer_right, PDM_SAMPLE_SIZE * DECIMATION_M,
                    pcm_buffer_right, &filter_right);
            for (int i = 0; i < PDM_SAMPLE_SIZE; i++) {
                pcm.push_back((int16_t)(pcm_buffer_left[i] / 64));
                pcm.push_back((int16_t)(pcm_buffer_right[i] / 64));
                if (pcm_buffer_left[i] > max)
                    max = pcm_buffer_left[i];
                if (pcm_buffer_left[i] < min)
                    min = pcm_buffer_left[i];
            }
        }
    }
}

void AUDIOSIM::bypass(int16_t left, int16_t right) {
    bypass_counter++;
    if (bypass_counter == DECIMATION_M) {
        bypass_counter = 0;
        byp.push_back(left);
        byp.push_back(right);
    }
}