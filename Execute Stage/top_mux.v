`timescale 1ns / 1ps
/*
 * top_mux (32-bit)
 * Selects ALU operand B:
 *   alusrc = 0 → use rdata2 (register value)
 *   alusrc = 1 → use s_extend (sign-extended immediate)
 */
module top_mux(
    input  wire [31:0] a,      // s_extend
    input  wire [31:0] b,      // rdata2
    input  wire       alusrc,  // ALUSrc
    output wire [31:0] y
);
    assign y = alusrc ? a : b;
endmodule
