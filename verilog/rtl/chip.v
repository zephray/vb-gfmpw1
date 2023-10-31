`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    18:48:36 02/14/2018 
// Design Name: 
// Module Name:    ppu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//   Chip top level
// Additional Comments: 
//   Wraps up the VerilogBoy and expose signals to be connected to the pad frame
//////////////////////////////////////////////////////////////////////////////////
module chip(
    input wire clk, // 4 MHz clock input
    input wire rstn, // Active high sync reset
    output reg [15:0] a, // Address bus
    output reg [7:0] dout, // Data bus to be written
    input wire [7:0] din, // Data bus read
    output reg doe, // Data bus output enable
    output reg wr, // High active write enable
    output reg cale, // Cartridge address latch enable
    output reg cs, // Cartridge chip select
    output wire hsync, // LCD horizontal sync
    output wire vsync, // LCD vertical sync
    output wire csync, // LCD composite sync
    output wire pvalid, // LCD pixel valid/ clock gate
    output wire [1:0] pixel, // LCD pixel output
    input wire skey, // Serial key input
    output wire audiolr, // Audio left/right output
    // For testbench only
    output wire done,
    output wire fault
);
    wire rst = !rstn;

    wire [1:0] ct;
    wire [15:0] cpu_a;
    wire [7:0] cpu_dout;
    reg [7:0] cpu_din;
    wire cpu_wr;
    wire cpu_rd;
    reg [7:0] key;
    wire [15:0] ppu_a;
    wire [7:0] ppu_dout;
    reg [7:0] ppu_din;
    wire ppu_wr;
    wire ppu_rd;
    wire [15:0] left;
    wire [15:0] right;

    boy boy(
        .rst(rst), // Async Reset Input
        .clk(clk), // 4.19MHz Clock Input
        .phi(), // 1.05MHz Reference Clock Output
        .ct(ct), // 0-3T cycle number
        // Cartridge interface
        .a(cpu_a), // Address Bus
        .dout(cpu_dout),  // Data Bus
        .din(cpu_din),
        .wr(cpu_wr), // Write Enable
        .rd(cpu_rd), // Read Enable
        // Keyboard input
        .key(key),
        // LCD output
        .hs(hsync), // Horizontal Sync Output
        .vs(vsync), // Vertical Sync Output
        .cpl(), // Pixel Data Latch
        .pixel(pixel), // Pixel Data
        .valid(pvalid),
        // Sound output
        .left(left),
        .right(right),
        // Video RAM interface
        .ppu_a(ppu_a[12:0]),
        .ppu_wr(ppu_wr),
        .ppu_rd(ppu_rd),
        .ppu_din(ppu_din),
        .ppu_dout(ppu_dout),
        // Debug interface
        .done(done),
        .fault(fault)
    );

    assign csync = hsync ^ vsync;
    assign ppu_a[15:13] = 3'b100;

    // Internal SRAM (WRAM + VRAM, 16KB)
    // Address
    // 1000 xxxx xxxx xxxx VRAM
    // 1001 xxxx xxxx xxxx VRAM
    // 1100 xxxx xxxx xxxx WRAM
    // 1101 xxxx xxxx xxxx WRAM

    wire addr_is_ram = ((cpu_a >= 16'h8000) && (cpu_a <= 16'h9fff)) ||
            ((cpu_a >= 16'hc000) && (cpu_a <= 16'hdfff));
    wire addr_is_cart = ((cpu_a <= 16'h7fff) || // Cart ROM
            ((cpu_a >= 16'ha000) && (cpu_a <= 16'hbfff))); // Cart RAM

    reg addr_is_cart_reg;
    reg [15:0] cpu_a_reg;
    always @(posedge clk) begin
        if (ct == 2'b00) begin
            addr_is_cart_reg <= addr_is_cart;
            cpu_a_reg <= cpu_a;
        end
    end

    // Bus multiplexing
    always @(*) begin
        if (ct == 2'b00) begin
            // CPU/ DMA address output
            a = cpu_a;
            dout = 8'hff;
            doe = 1'b0;
            wr = 1'b0;
            cale = 1'b1;
            cs = 1'b0;
            cpu_din = 8'hff;
            ppu_din = 8'hff;
        end
        else if ((ct == 2'b01) || (ct == 2'b11)) begin
            // VRAM access (read only)
            a = ppu_a;
            dout = 8'hff;
            doe = 1'b0;
            wr = 1'b0;
            cale = 1'b0;
            cs = 1'b0;
            cpu_din = 8'hff;
            ppu_din = din;
        end
        else begin
            // CPU/ DMA access (RW)
            a = cpu_a_reg;
            dout = cpu_dout;
            doe = !cpu_wr;
            wr = cpu_wr;
            cale = 1'b0;
            cs = addr_is_cart_reg;
            cpu_din = din;
            ppu_din = 8'hff;
        end
    end

    // Audio PDM
    reg lrck;
    always @(posedge clk) begin
        if (rst) begin
            lrck <= 1'b0;
        end
        else begin
            lrck <= ~lrck;
        end
    end

    wire audiol;
    wire audior;

    sdm1b #(.W(9)) sdm_left (
        .clk_fast(clk),
        .rst(rst),
        .enable(lrck),
        .din(left[14:6]),
        .error(),
        .dout(audiol)
    );

    sdm1b #(.W(9)) sdm_right (
        .clk_fast(clk),
        .rst(rst),
        .enable(!lrck),
        .din(right[14:6]),
        .error(),
        .dout(audior)
    );

    assign audiolr = (lrck) ? (audiol) : (audior);

    // Key serial to parallel
    reg [7:0] key_sr;
    reg [3:0] counter;
    always @(posedge clk) begin
        if (csync) begin
            counter <= 4'b0;
        end
        else begin
            if (pvalid) begin
                if (counter != 4'd8) begin
                    key_sr <= {key_sr[6:0], skey};
                    counter <= counter + 1;
                end
                else begin
                    key <= key_sr;
                end
            end
        end
    end

endmodule
`default_nettype wire
