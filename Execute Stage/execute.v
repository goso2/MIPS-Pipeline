`timescale 1ns / 1ps
/*
 * Execute stage - standalone version that matches executeTB.v
 *
 * Uses:
 *   adder       - NPC + sign-extended immediate
 *   bottom_mux  - chooses destination register (rt vs rd)
 *   top_mux     - chooses ALU operand B (rdata2 vs immediate)
 *   alu_control - generates ALU control from alu_op + funct
 *   alu         - does the arithmetic / logic
 *   ex_mem      - EX/MEM "latch" from professor's code
 */
module execute(
    input  wire        clk,          // not used internally (combinational ex_mem), present for TB
    // input  wire        reset,

    // control coming into Execute (like ID/EX outputs)
    input  wire [1:0]  ctlwb_in,     // WB control
    input  wire [1:0]  ctlm_in,      // MEM control: {memread, memwrite}

    // data from ID/EX / Decode
    input  wire [31:0] npc,          // next PC
    input  wire [31:0] rdata1,       // rs value
    input  wire [31:0] rdata2,       // rt value
    input  wire [31:0] s_extend,     // sign-extended immediate

    input  wire [4:0]  instr_2016,   // rt field
    input  wire [4:0]  instr_1511,   // rd field

    // ALU control inputs
    input  wire [1:0]  alu_op,
    input  wire [5:0]  funct,        // Instr[5:0] - in full pipeline this comes from ID/EX latch

    // misc control
    input  wire        alusrc,       // choose between rdata2 / immediate
    input  wire        regdst,       // choose between rt / rd

    // outputs observed by executeTB (plus what EX/MEM would send forward)
    output wire [1:0]  ctlwb_out,    // WB control after EX/MEM
    output wire [1:0]  ctlm_out,     // {memread, memwrite} after EX/MEM
    output wire [31:0] adder_out,    // branch target from EX/MEM
    output wire [31:0] alu_result_out,
    output wire [31:0] rdata2_out,   // forwarded rt for store
    output wire [4:0]  muxout_out    // chosen destination register
);

    // ---------- internal wires ----------
    wire [31:0] adder_result;
    wire [31:0] alu_b;
    wire [2:0]  alu_ctrl;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [4:0]  dest_reg;

    // ex_mem outputs
    wire [1:0]  wb_ctlout_w;
    wire        branch_w;
    wire        memread_w;
    wire        memwrite_w;
    wire [31:0] add_result_w;
    wire        zero_w;
    wire [31:0] alu_result_w;
    wire [31:0] rdata2out_w;
    wire [4:0]  muxout_w;

    // expand 2-bit MEM control into 3-bit bus for ex_mem:
    //   ctlm_in_3[2] = branch (unused here, set 0)
    //   ctlm_in_3[1] = memread
    //   ctlm_in_3[0] = memwrite
    wire [2:0] ctlm_in_3 = {1'b0, ctlm_in};

    // ---------- NPC + sign-extended immediate ----------
    adder u_adder (
        .add_in1(npc),
        .add_in2(s_extend),
        .add_out(adder_result)
    );

    // ---------- ALUSrc mux: choose ALU operand B ----------
    top_mux u_top_mux (
        .a     (s_extend),
        .b     (rdata2),
        .alusrc(alusrc),
        .y     (alu_b)
    );

    // ---------- ALU control ----------
    alu_control u_alu_control (
        .funct (funct),
        .aluop (alu_op),
        .select(alu_ctrl)
    );

    // ---------- ALU ----------
    alu u_alu (
        .a      (rdata1),
        .b      (alu_b),
        .control(alu_ctrl),
        .result (alu_result),
        .zero   (alu_zero)
    );

    // ---------- RegDst mux: choose destination register ----------
    bottom_mux u_bottom_mux (
        .a  (instr_1511),  // rd
        .b  (instr_2016),  // rt
        .sel(regdst),
        .y  (dest_reg)
    );

    // ---------- EX/MEM latch (professor's code) ----------
    ex_mem u_ex_mem (
        .ctlwb_out(ctlwb_in),
        .ctlm_out (ctlm_in_3),
        .adder_out(adder_result),
        .aluzero  (alu_zero),
        .aluout   (alu_result),
        .readdat2 (rdata2),
        .muxout   (dest_reg),

        .wb_ctlout      (wb_ctlout_w),
        .branch         (branch_w),
        .memread        (memread_w),
        .memwrite       (memwrite_w),
        .add_result     (add_result_w),
        .zero           (zero_w),
        .alu_result     (alu_result_w),
        .rdata2out      (rdata2out_w),
        .five_bit_muxout(muxout_w)
    );

    // ---------- hook up to testbench outputs ----------
    assign ctlwb_out      = wb_ctlout_w;
    assign ctlm_out       = {memread_w, memwrite_w};  // pack MEM control back into 2 bits
    assign adder_out      = add_result_w;
    assign alu_result_out = alu_result_w;
    assign rdata2_out     = rdata2out_w;
    assign muxout_out     = muxout_w;

endmodule
