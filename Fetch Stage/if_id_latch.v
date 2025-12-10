`timescale 1ns/1ps
// IF/ID Latch
// - Captures PC+4 (aka npc) and fetched instruction on clk
// - Synchronous reset clears outputs to 0
module ifIdLatch (
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] pc_in,     // typically PC+4 (next PC)
  input  wire [31:0] instr_in,  // fetched instruction
  output reg  [31:0] pc_out,
  output reg  [31:0] instr_out
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      pc_out    <= 32'h0000_0000;
      instr_out <= 32'h0000_0000;
    end else begin
      pc_out    <= pc_in;
      instr_out <= instr_in;
    end
  end
endmodule
