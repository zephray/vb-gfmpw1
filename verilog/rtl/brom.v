`timescale 1ns/1ps
module brom(
    input [7:0] a,
    output reg [7:0] d
);
always@(*)
    case (a)
        8'h00: d = 8'h31;
        8'h01: d = 8'hFE;
        8'h02: d = 8'hFF;
        8'h03: d = 8'hAF;
        8'h04: d = 8'h21;
        8'h05: d = 8'hFF;
        8'h06: d = 8'h9F;
        8'h07: d = 8'h32;
        8'h08: d = 8'hCB;
        8'h09: d = 8'h7C;
        8'h0A: d = 8'h20;
        8'h0B: d = 8'hFB;
        8'h0C: d = 8'h3E;
        8'h0D: d = 8'h00;
        8'h0E: d = 8'hE0;
        8'h0F: d = 8'h42;
        8'h10: d = 8'h3E;
        8'h11: d = 8'h91;
        8'h12: d = 8'hE0;
        8'h13: d = 8'h40;
        8'h14: d = 8'h3E;
        8'h15: d = 8'h01;
        8'h16: d = 8'hC3;
        8'h17: d = 8'hFE;
        8'h18: d = 8'h00;
        8'h19: d = 8'h00;
        8'h1A: d = 8'h00;
        8'h1B: d = 8'h00;
        8'h1C: d = 8'h00;
        8'h1D: d = 8'h00;
        8'h1E: d = 8'h00;
        8'h1F: d = 8'h00;
        8'h20: d = 8'h00;
        8'h21: d = 8'h00;
        8'h22: d = 8'h00;
        8'h23: d = 8'h00;
        8'h24: d = 8'h00;
        8'h25: d = 8'h00;
        8'h26: d = 8'h00;
        8'h27: d = 8'h00;
        8'h28: d = 8'h00;
        8'h29: d = 8'h00;
        8'h2A: d = 8'h00;
        8'h2B: d = 8'h00;
        8'h2C: d = 8'h00;
        8'h2D: d = 8'h00;
        8'h2E: d = 8'h00;
        8'h2F: d = 8'h00;
        8'h30: d = 8'h00;
        8'h31: d = 8'h00;
        8'h32: d = 8'h00;
        8'h33: d = 8'h00;
        8'h34: d = 8'h00;
        8'h35: d = 8'h00;
        8'h36: d = 8'h00;
        8'h37: d = 8'h00;
        8'h38: d = 8'h00;
        8'h39: d = 8'h00;
        8'h3A: d = 8'h00;
        8'h3B: d = 8'h00;
        8'h3C: d = 8'h00;
        8'h3D: d = 8'h00;
        8'h3E: d = 8'h00;
        8'h3F: d = 8'h00;
        8'h40: d = 8'h00;
        8'h41: d = 8'h00;
        8'h42: d = 8'h00;
        8'h43: d = 8'h00;
        8'h44: d = 8'h00;
        8'h45: d = 8'h00;
        8'h46: d = 8'h00;
        8'h47: d = 8'h00;
        8'h48: d = 8'h00;
        8'h49: d = 8'h00;
        8'h4A: d = 8'h00;
        8'h4B: d = 8'h00;
        8'h4C: d = 8'h00;
        8'h4D: d = 8'h00;
        8'h4E: d = 8'h00;
        8'h4F: d = 8'h00;
        8'h50: d = 8'h00;
        8'h51: d = 8'h00;
        8'h52: d = 8'h00;
        8'h53: d = 8'h00;
        8'h54: d = 8'h00;
        8'h55: d = 8'h00;
        8'h56: d = 8'h00;
        8'h57: d = 8'h00;
        8'h58: d = 8'h00;
        8'h59: d = 8'h00;
        8'h5A: d = 8'h00;
        8'h5B: d = 8'h00;
        8'h5C: d = 8'h00;
        8'h5D: d = 8'h00;
        8'h5E: d = 8'h00;
        8'h5F: d = 8'h00;
        8'h60: d = 8'h00;
        8'h61: d = 8'h00;
        8'h62: d = 8'h00;
        8'h63: d = 8'h00;
        8'h64: d = 8'h00;
        8'h65: d = 8'h00;
        8'h66: d = 8'h00;
        8'h67: d = 8'h00;
        8'h68: d = 8'h00;
        8'h69: d = 8'h00;
        8'h6A: d = 8'h00;
        8'h6B: d = 8'h00;
        8'h6C: d = 8'h00;
        8'h6D: d = 8'h00;
        8'h6E: d = 8'h00;
        8'h6F: d = 8'h00;
        8'h70: d = 8'h00;
        8'h71: d = 8'h00;
        8'h72: d = 8'h00;
        8'h73: d = 8'h00;
        8'h74: d = 8'h00;
        8'h75: d = 8'h00;
        8'h76: d = 8'h00;
        8'h77: d = 8'h00;
        8'h78: d = 8'h00;
        8'h79: d = 8'h00;
        8'h7A: d = 8'h00;
        8'h7B: d = 8'h00;
        8'h7C: d = 8'h00;
        8'h7D: d = 8'h00;
        8'h7E: d = 8'h00;
        8'h7F: d = 8'h00;
        8'h80: d = 8'h00;
        8'h81: d = 8'h00;
        8'h82: d = 8'h00;
        8'h83: d = 8'h00;
        8'h84: d = 8'h00;
        8'h85: d = 8'h00;
        8'h86: d = 8'h00;
        8'h87: d = 8'h00;
        8'h88: d = 8'h00;
        8'h89: d = 8'h00;
        8'h8A: d = 8'h00;
        8'h8B: d = 8'h00;
        8'h8C: d = 8'h00;
        8'h8D: d = 8'h00;
        8'h8E: d = 8'h00;
        8'h8F: d = 8'h00;
        8'h90: d = 8'h00;
        8'h91: d = 8'h00;
        8'h92: d = 8'h00;
        8'h93: d = 8'h00;
        8'h94: d = 8'h00;
        8'h95: d = 8'h00;
        8'h96: d = 8'h00;
        8'h97: d = 8'h00;
        8'h98: d = 8'h00;
        8'h99: d = 8'h00;
        8'h9A: d = 8'h00;
        8'h9B: d = 8'h00;
        8'h9C: d = 8'h00;
        8'h9D: d = 8'h00;
        8'h9E: d = 8'h00;
        8'h9F: d = 8'h00;
        8'hA0: d = 8'h00;
        8'hA1: d = 8'h00;
        8'hA2: d = 8'h00;
        8'hA3: d = 8'h00;
        8'hA4: d = 8'h00;
        8'hA5: d = 8'h00;
        8'hA6: d = 8'h00;
        8'hA7: d = 8'h00;
        8'hA8: d = 8'h00;
        8'hA9: d = 8'h00;
        8'hAA: d = 8'h00;
        8'hAB: d = 8'h00;
        8'hAC: d = 8'h00;
        8'hAD: d = 8'h00;
        8'hAE: d = 8'h00;
        8'hAF: d = 8'h00;
        8'hB0: d = 8'h00;
        8'hB1: d = 8'h00;
        8'hB2: d = 8'h00;
        8'hB3: d = 8'h00;
        8'hB4: d = 8'h00;
        8'hB5: d = 8'h00;
        8'hB6: d = 8'h00;
        8'hB7: d = 8'h00;
        8'hB8: d = 8'h00;
        8'hB9: d = 8'h00;
        8'hBA: d = 8'h00;
        8'hBB: d = 8'h00;
        8'hBC: d = 8'h00;
        8'hBD: d = 8'h00;
        8'hBE: d = 8'h00;
        8'hBF: d = 8'h00;
        8'hC0: d = 8'h00;
        8'hC1: d = 8'h00;
        8'hC2: d = 8'h00;
        8'hC3: d = 8'h00;
        8'hC4: d = 8'h00;
        8'hC5: d = 8'h00;
        8'hC6: d = 8'h00;
        8'hC7: d = 8'h00;
        8'hC8: d = 8'h00;
        8'hC9: d = 8'h00;
        8'hCA: d = 8'h00;
        8'hCB: d = 8'h00;
        8'hCC: d = 8'h00;
        8'hCD: d = 8'h00;
        8'hCE: d = 8'h00;
        8'hCF: d = 8'h00;
        8'hD0: d = 8'h00;
        8'hD1: d = 8'h00;
        8'hD2: d = 8'h00;
        8'hD3: d = 8'h00;
        8'hD4: d = 8'h00;
        8'hD5: d = 8'h00;
        8'hD6: d = 8'h00;
        8'hD7: d = 8'h00;
        8'hD8: d = 8'h00;
        8'hD9: d = 8'h00;
        8'hDA: d = 8'h00;
        8'hDB: d = 8'h00;
        8'hDC: d = 8'h00;
        8'hDD: d = 8'h00;
        8'hDE: d = 8'h00;
        8'hDF: d = 8'h00;
        8'hE0: d = 8'h00;
        8'hE1: d = 8'h00;
        8'hE2: d = 8'h00;
        8'hE3: d = 8'h00;
        8'hE4: d = 8'h00;
        8'hE5: d = 8'h00;
        8'hE6: d = 8'h00;
        8'hE7: d = 8'h00;
        8'hE8: d = 8'h00;
        8'hE9: d = 8'h00;
        8'hEA: d = 8'h00;
        8'hEB: d = 8'h00;
        8'hEC: d = 8'h00;
        8'hED: d = 8'h00;
        8'hEE: d = 8'h00;
        8'hEF: d = 8'h00;
        8'hF0: d = 8'h00;
        8'hF1: d = 8'h00;
        8'hF2: d = 8'h00;
        8'hF3: d = 8'h00;
        8'hF4: d = 8'h00;
        8'hF5: d = 8'h00;
        8'hF6: d = 8'h00;
        8'hF7: d = 8'h00;
        8'hF8: d = 8'h00;
        8'hF9: d = 8'h00;
        8'hFA: d = 8'h00;
        8'hFB: d = 8'h00;
        8'hFC: d = 8'h00;
        8'hFD: d = 8'h00;
        8'hFE: d = 8'hE0;
        8'hFF: d = 8'h50;
    endcase
endmodule