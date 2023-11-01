module gf180_ram_512x8_wrapper (CEN,
    CLK,
    GWEN,
    VDD,
    VSS,
    A,
    D,
    Q,
    WEN);
 input CEN;
 input CLK;
 input GWEN;
 input VDD;
 input VSS;
 input [8:0] A;
 input [7:0] D;
 output reg [7:0] Q;
 input [7:0] WEN;

    reg [7:0] ram [0:512-1];
    
    always@(posedge CLK) begin
        if (!CEN && !GWEN)
            ram[A] <= D;
    end
    
    always@(posedge CLK) begin
        if (!CEN)
            Q <= ram[A];
        else
            Q <= 8'bx;
    end

endmodule
