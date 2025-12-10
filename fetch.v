`timescale 1ns/1ps
// Final IF Stage: wires all 5 components
//
// Interface (matches your incomplete testbench stub):
//  - ex_mem_pc_src : 1 selects ex_mem_npc (e.g., branch/jump resolved), 0 selects PC+4
//  - ex_mem_npc    : target address to use when ex_mem_pc_src=1
//  - Outputs if_id_instr (fetched instruction) and if_id_npc (latched PC+4)
//
// Internals:
//  PC --(pc_out)--> incrementer(+4) --> mux (vs ex_mem_npc) --> PC_in
//  instrMem reads instruction at PC_out (byte address)
//  IF/ID latch captures (PC+4, instr)
module fetch(
  input  wire        clk,
  input  wire        rst,
  input  wire        ex_mem_pc_src,
  input  wire [31:0] ex_mem_npc,
  output wire [31:0] if_id_instr,
  output wire [31:0] if_id_npc
);

  // internal wires
  wire [31:0] pc_out;
  wire [31:0] pc_plus4;
  wire [31:0] pc_next;
  wire [31:0] instr_data;

  // MUX: choose next PC
  mux2 #(32) m0 (
    .a_true (ex_mem_npc),   // if taken
    .b_false(pc_plus4),     // otherwise sequential
    .sel    (ex_mem_pc_src),
    .y      (pc_next)
  );

  // PC register
  pc pc0(
    .clk   (clk),
    .rst   (rst),
    .pc_in (pc_next),
    .pc_out(pc_out)
  );

  // PC incrementer (+4)
  incrementer in0(
    .pcin (pc_out),
    .pcout(pc_plus4)
  );

  // Instruction memory read @ pc_out (byte address)
  instrMem inMem0(
    .clk (clk),
    .rst (rst),
    .addr(pc_out),
    .data(instr_data)
  );

  // IF/ID latch
  ifIdLatch ifIdLatch0(
    .clk      (clk),
    .rst      (rst),
    .pc_in    (pc_plus4),    // convention: npc = pc+4
    .instr_in (instr_data),
    .pc_out   (if_id_npc),
    .instr_out(if_id_instr)
  );

endmodule
