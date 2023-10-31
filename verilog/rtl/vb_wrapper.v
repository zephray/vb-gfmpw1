`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    17:30:26 02/08/2018 
// Module Name:    vb_wrapper
// Project Name:   VerilogBoy
// Description: 
//   Wraps up chip module to be embedded in user_project_wrapper
////////////////////////////////////////////////////////////////////////////////

module vb_wrapper(
`ifdef USE_POWER_PINS
    inout vdd,	// User area 1 1.8V supply
    inout vss,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [63:0] la_data_in,
    output [63:0] la_data_out,
    input  [63:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    // Local wires
    wire clk; // 4 MHz clock input
    wire rstn; // Active high sync reset
    wire [15:0] a; // Address bus
    wire [7:0] dout; // Data bus to be written
    wire [7:0] din; // Data bus read
    wire doe; // Data bus output enable
    wire wr; // High active write enable
    wire csync; // LCD composite sync
    wire pvalid; // LCD pixel valid/ clock gate
    wire [1:0] pixel; // LCD pixel output
    wire skey; // Serial key input
    wire audiolr; // Audio output
    wire mode; // Test mode

    // Tie off wishbone
    assign wbs_ack_o = 1'b0;
    assign wbs_dat_o = 32'b0;

    // Tie off logic analyzer signals
    assign la_data_out = 64'b0;

    // Tie off IRQs
    assign irq = 3'b0;

    // Connect IOs
    assign io_out[4:0] = 5'd0;
    assign io_oeb[4:0] = 5'd0;

    assign clk = io_in[5];
    assign io_out[5] = 1'b0;
    assign io_oeb[5] = 1'b1;

    assign rstn = io_in[6];
    assign io_out[6] = 1'b0;
    assign io_oeb[6] = 1'b1;

    assign io_out[22:7] = a;
    assign io_oeb[22:7] = 16'd0;

    assign din = io_in[30:23];
    assign io_out[30:23] = dout;
    assign io_oeb[30:23] = ~{8{doe}};

    assign io_out[31] = wr;
    assign io_oeb[31] = 1'b0;

    assign io_out[32] = csync;
    assign io_oeb[32] = 1'b0;

    assign io_out[33] = pvalid;
    assign io_oeb[33] = 1'b0;

    assign io_out[35:34] = pixel;
    assign io_oeb[35:34] = 2'd0;

    assign skey = io_in[36];
    assign io_out[36] = 1'b0;
    assign io_oeb[36] = 1'b1;

    assign io_out[37] = audiolr;
    assign io_oeb[37] = 1'b0;

    // Modules
    chip chip(
        .clk(clk),
        .rstn(rstn),
        .a(a),
        .dout(dout),
        .din(din),
        .doe(doe),
        .wr(wr),
        .csync(csync),
        .pvalid(pvalid),
        .pixel(pixel),
        .skey(skey),
        .audiolr(audiolr)
    );


endmodule