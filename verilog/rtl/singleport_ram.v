`timescale 1ns / 1ps
module singleport_ram #(
    parameter integer WORDS = 8192,
    parameter ABITS = $clog2(WORDS)
)(
    input clka,
    input wea,
    input [ABITS - 1:0] addra,
    input [7:0] dina,
    output reg [7:0] douta
);

`define USE_SRAM

`ifdef USE_SRAM
    localparam N = WORDS / 512;
    wire [ABITS-9-1:0] ahi = addra[ABITS-1:9];
    wire [8:0] alo = addra[8:0];
    wire [7:0] dout [N];
    reg [N-1:0] sel_reg;
    generate genvar i;
    for (i = 0; i < N; i = i + 1) begin
        wire sel = (ahi == i);
        gf180_ram_512x8_wrapper mem0 (
            .CEN(!sel),
            .CLK(clka),
            .GWEN(!wea),
            .A(alo),
            .D(dina),
            .Q(dout[i]),
            .WEN(8'd0)
        );
        always @(posedge clka)
            sel_reg[i] <= sel;
    end
    endgenerate
    always @(*) begin
        integer i;
        douta = 8'd0;
        for (i = 0; i < N; i = i + 1) begin
            douta |= {8{sel_reg[i]}} & dout[i];
        end
    end
`else
    reg [7:0] ram [0:WORDS-1];
    
    always@(posedge clka) begin
        if (wea)
            ram[addra] <= dina;
    end
    
    always@(posedge clka) begin
        douta <= ram[addra];
    end
`endif

endmodule
