`timescale 1ns / 1ps
/*
 * bottom_mux (5-bit)
 * Selects which register number will be written:
 *   sel = 0 → use instr[20:16] (rt, I-type)
 *   sel = 1 → use instr[15:11] (rd, R-type)
 */
module bottom_mux(
    input  wire [4:0] a,   // usually rd  (instr_1511)
    input  wire [4:0] b,   // usually rt  (instr_2016)
    input  wire       sel, // RegDst
    output wire [4:0] y
);
    assign y = sel ? a : b;
endmodule
