`timescale 1ns/1ps
// Program Counter (PC)
// - Synchronous reset to 0
// - On each clk, captures pc_in -> pc_out
module pc (
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] pc_in,
  output reg  [31:0] pc_out
);
  always @(posedge clk or posedge rst) begin
    if (rst) pc_out <= 32'h0000_0000;
    else     pc_out <= pc_in;
  end
endmodule
