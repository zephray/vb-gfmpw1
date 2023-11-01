`timescale 1ns / 1ps
`default_nettype wire
module async_ram #(
    parameter integer WORDS = 8192,
    parameter ABITS = 13
)(
    input clka,
    input wea,
    input [ABITS - 1:0] addra,
    input [7:0] dina,
    output [7:0] douta
);

    reg [7:0] ram [0:WORDS-1];
    
    always@(posedge clka) begin
        if (wea)
            ram[addra] <= dina;
    end
    
    assign douta = ram[addra];

endmodule
