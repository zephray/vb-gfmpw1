`timescale 1ns / 1ps
// MIT License
//
// Copyright (c) 2022 andylithia
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//==============================================================================
//
// Generic 12bit to 1bit Sigma-Delta Modulator
// with LSB dithering capability
//
module sdm1b #(
    parameter integer W         = 12,
    parameter integer ADD_NOISE = 1
) (
    input          clk_fast,
    input          rst,
    input          enable,
    input  [W-1:0] din,
    output [W-1:0] error,
    output         dout
);

    wire [1:0] lfsr_bit;
    lfsr_prbs_gen #(
        .LFSR_WIDTH(16),
        .DATA_WIDTH(2),
        .LFSR_INIT (16'hBEEF),
        .STYLE     ("AUTO")
    ) u_LFSR(
        .clk     (clk_fast),
        .rst     (rst),
        .enable  (enable),
        .data_out(lfsr_bit)
    );
    reg [W:0] acc_r = 0;
    assign dout  = acc_r[W];
    assign error = acc_r[W-1:0];
    always @(posedge clk_fast) begin
        if (rst) begin
            acc_r <= 0;
        end else begin
            if (enable) begin
                if(ADD_NOISE) acc_r <= din + error ^ lfsr_bit[0];
                else          acc_r <= din + error;
            end
        end
    end
endmodule  /* sdm1b */