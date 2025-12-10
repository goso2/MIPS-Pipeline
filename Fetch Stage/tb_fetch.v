`timescale 1ns/1ps

module tb_fetch;

  reg         clk;
  reg         rst;
  reg         ex_mem_pc_src;
  reg  [31:0] ex_mem_npc;
  wire [31:0] if_id_instr;
  wire [31:0] if_id_npc;

  // DUT
  fetch dut (
    .clk          (clk),
    .rst          (rst),
    .ex_mem_pc_src(ex_mem_pc_src),
    .ex_mem_npc   (ex_mem_npc),
    .if_id_instr  (if_id_instr),
    .if_id_npc    (if_id_npc)
  );

  // clock gen: 10ns period
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // stimulus
  initial begin
    // waveform dump (iverilog/gtkwave)
    $dumpfile("tb_fetch.vcd");
    $dumpvars(0, tb_fetch);

    // init
    rst = 1'b1;
    ex_mem_pc_src = 1'b0;     // follow PC+4
    ex_mem_npc    = 32'h0000_0020; // target if we take a branch
    repeat (2) @(posedge clk);
    rst = 1'b0;

    // Let it fetch sequentially for a few cycles
    repeat (5) @(posedge clk);

    // Simulate a taken branch/jump for one cycle
    ex_mem_pc_src = 1'b1; // choose ex_mem_npc on next edge
    @(posedge clk);

    // Return to sequential fetch
    ex_mem_pc_src = 1'b0;
    repeat (5) @(posedge clk);

    $finish;
  end

  // handy monitors
  always @(posedge clk) begin
    $display("T=%0t | PC+4(IF/ID)=0x%08h  INSTR=0x%08h  pc_src=%0d  npc=0x%08h",
             $time, if_id_npc, if_id_instr, ex_mem_pc_src, ex_mem_npc);
  end

endmodule
