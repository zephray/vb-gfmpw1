`timescale 1ns / 1ps
`default_nettype wire
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    17:30:26 02/08/2018 
// Module Name:    simtop
// Project Name:   VerilogBoy
// Description: 
//   Top-level wrapper for RTL simulation
////////////////////////////////////////////////////////////////////////////////
module simtop(
    input wire clk,
    input wire rst,
    // Cartridge interface
    output wire [15:0] a,
    output wire [7:0] dout,
    input wire [7:0] din,
    output wire wr,
    output wire rd,
    // Keyboard input
    input wire [7:0] key,
    // LCD output
    output wire hs,
    output wire vs,
    output wire [1:0] pixel,
    output wire valid,
    // Audio output
    output reg audiol,
    output reg audior,
    // For testbench only
    output wire done,
    output wire fault
    );

    wire [15:0] bus_a;
    wire [7:0] bus_dout;
    wire [7:0] bus_dout_enabled;
    wire [7:0] bus_din;
    wire [7:0] bus_din_enabled;
    wire bus_doe;
    wire bus_wr;
    wire bus_cale;
    wire bus_cs;
    wire csync;
    wire skey;
    wire audiolr;

    chip chip(
        .clk(clk),
        .rstn(!rst),
        .a(bus_a),
        .dout(bus_dout),
        .din(bus_din_enabled),
        .doe(bus_doe),
        .wr(bus_wr),
        .hsync(hs),
        .vsync(vs),
        .csync(csync),
        .pvalid(valid),
        .pixel(pixel),
        .skey(skey),
        .audiolr(audiolr),
        .done(done),
        .fault(fault)
    );
    assign bus_dout_enabled = bus_dout & {8{bus_doe}};
    assign bus_din_enabled = bus_din & ~{8{bus_doe}};
    //assign bus_dout_enabled = bus_dout;
    //assign bus_din_enabled = bus_din;

    assign bus_cs = (!bus_a[15] || (bus_a[15:13] == 3'b101));

    wire sram_we;
    wire [7:0] sram_dout;
    async_ram #(.WORDS(8192), .ABITS(13)) sram(
        .clka(clk),
        .wea(sram_we),
        .addra(bus_a[12:0]),
        .dina(bus_dout_enabled),
        .douta(sram_dout)
    );
    assign sram_we = bus_wr & !bus_cs;

    assign a = bus_a;
    assign dout = bus_dout_enabled;
    assign bus_din = bus_cs ? din : sram_dout;
    assign wr = bus_cs & bus_wr;
    assign rd = ~bus_wr; // Always enable output

    // Key parallel to serial
    reg [7:0] key_sr;
    always @(posedge clk) begin
        if (csync) begin
            key_sr <= key;
        end
        else if (valid) begin
            key_sr <= {key_sr[6:0], 1'b0};
        end
    end
    assign skey = key_sr[7];

    reg lrck;
    always @(posedge clk) begin
        if (rst) begin
            lrck <= 1'b0;
        end
        else begin
            lrck <= ~lrck;
            if (lrck) begin
                audiol <= audiolr;
            end
            else begin
                audior <= audiolr;
            end
        end
    end

endmodule
