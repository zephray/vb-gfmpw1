// Software CIC
// https://blog.y2kb.com/posts/pdm-mic-spi-cic/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "cic.h"

void initializeCicFilterStruct(uint8_t CicFilterOrder, uint32_t CicFilterDecimation, struct CicFilter_t* st)
{
    if (CicFilterOrder == 0)
    {
        printf("Order of CIC filter must be over 0\r\n");
        return;
    }
    if(CicFilterDecimation == 0)
    {
        printf("Decimation of CIC filter must be over 0\r\n");
        return;
    }
    st->order = CicFilterOrder;
    st->decimation = CicFilterDecimation;
    st->out_i = (int32_t*) malloc(sizeof(int32_t) * st->order);
    st->out_c = (int32_t*) malloc(sizeof(int32_t) * st->order);
    st->z1_c  = (int32_t*) malloc(sizeof(int32_t) * st->order);
    
    if ((st->out_i == NULL) || (st->out_c == NULL) || (st->z1_c == NULL))
    {
        printf("CicFilterStruct malloc error\r\n");
        return;
    }
    resetCicFilterStruct(st);
}

void resetCicFilterStruct(struct CicFilter_t* st)
{
    if(st == NULL)
        return;
    
    for(uint8_t i = 0; i < st->order; i++)
    {
        *(st->out_i + i) = 0;
        *(st->out_c + i) = 0;
        *(st->z1_c  + i) = 0;
    }
}

void executeCicFilter(uint8_t* pInBit, uint32_t pInBit_Num, int32_t* pOut_int32, struct CicFilter_t* st)
{
    //uint8_t Bout = st->order * (uint8_t)(ceil(log2f(st->decimation))) + 1;
    int32_t in_bit;
    uint8_t in_Byte;
    uint32_t Bit_i, Decimation_count;
    uint8_t i;

    for(Bit_i = 0, Decimation_count = st->decimation - 1; Bit_i < pInBit_Num; ++Bit_i, --Decimation_count)
    {
        in_Byte = *(pInBit + (Bit_i >> 3) );
        if( (in_Byte >> (Bit_i & 0x07)) & 0x01 )    // First bit is [b0]
            in_bit = 1;
        else
            in_bit = -1;

        // Integrator (No need to consider saturation.
        //   ref : http://d.hatena.ne.jp/suikan+blackfin/20060611/1149996053 (Japanese) )
        *(st->out_i) += in_bit;

        for (i = 1; i < st->order; ++i)
        {
            *(st->out_i + i) += *(st->out_i + i - 1);
        }

        // Decimation
        if(Decimation_count == 0)
        {
            Decimation_count = st->decimation;

            // Comb filter
            *(st->out_c) = *(st->out_i + st->order - 1) - *(st->z1_c);
            *(st->z1_c)  = *(st->out_i + st->order - 1);

            for (i = 1; i < st->order; ++i)
            {
                *(st->out_c + i) = *(st->out_c + i - 1) - *(st->z1_c + i);
                *(st->z1_c  + i) = *(st->out_c + i - 1);
            }

            *(pOut_int32 + Bit_i / st->decimation) = *(st->out_c + st->order - 1);
        }
    }
}

void finalizeCicFilterStruct(struct CicFilter_t* st)
{
    if (st == NULL)
        return;
    
    st->order = 0;
    st->decimation = 0;
    free(st->out_i);
    free(st->out_c);
    free(st->z1_c);
}
