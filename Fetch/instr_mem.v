`timescale 1ns/1ps
// Instruction Memory (word-addressable view)
module instrMem #(
  parameter DEPTH_WORDS = 1024  // practical size for sim
)(
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] addr,   // byte address
  output wire [31:0] data    // 32-bit instruction word
);

  // Word memory
  reg [31:0] mem [0:DEPTH_WORDS-1];

  // Word index: drop bottom 2 bits (word aligned)
  wire [$clog2(DEPTH_WORDS)-1:0] word_index = addr[ ($clog2(DEPTH_WORDS)+1) : 2 ];

  assign data = mem[word_index];

  integer i;
  initial begin
    // Clear memory (optional)
    for (i = 0; i < DEPTH_WORDS; i = i + 1) begin
      mem[i] = 32'h0000_0000;
    end

    // Load instruction memory from file
    // Each line in instr.mem is a 32-bit binary value like:
    // 100011_00000_00001_0000_0000_0000_0001
    $readmemb("instr.mem", mem);
  end

endmodule