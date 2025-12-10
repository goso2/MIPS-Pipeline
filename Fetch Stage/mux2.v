`timescale 1ns/1ps
// 2:1 MUX (default width 32)
// y = sel ? a_true : b_false
module mux2 #(parameter WIDTH = 32) (
  input  wire [WIDTH-1:0] a_true,
  input  wire [WIDTH-1:0] b_false,
  input  wire             sel,
  output wire [WIDTH-1:0] y
);
  assign y = (sel) ? a_true : b_false;
endmodule
