`timescale 1ns / 1ps

//============================================================
// Top-level MIPS 5-stage pipeline
// Matches professor's testbench: mips_pipeline_tb
//
//  Stages (your existing modules):
//    IF  : fetch.v
//    ID  : decode.v
//    EX  : execute.v
//    MEM : mem_stage.v (d_mem + MEM_WB + PCSrc)
//    WB  : wb_stage.v
//============================================================
module mips_pipeline (
    input  wire clk,
    input  wire rst
);

    //========================================================
    // IF/ID wires (Fetch -> Decode)
    //========================================================
    wire [31:0] if_id_instr;    // instruction from instruction memory
    wire [31:0] if_id_npc;      // PC + 4

    //========================================================
    // ID/EX wires (Decode -> Execute)
    //========================================================
    wire [1:0]  id_ex_wb;           // WB control (2 bits)
    wire [2:0]  id_ex_mem;          // MEM control: {Branch, MemRead, MemWrite}
    wire [3:0]  id_ex_execute;      // EX control: {RegDst, ALUOp[1:0], ALUSrc}

    wire [31:0] id_ex_npc;
    wire [31:0] id_ex_readdat1;
    wire [31:0] id_ex_readdat2;
    wire [31:0] id_ex_sign_ext;
    wire [4:0]  id_ex_instr_bits_20_16; // rt
    wire [4:0]  id_ex_instr_bits_15_11; // rd

    //========================================================
    // EX/MEM wires (Execute -> MEM stage + PC control)
    //========================================================
    wire [1:0]  ex_mem_wb;           // WB control after EX/MEM
    wire [1:0]  ex_mem_mem;          // {MemRead, MemWrite} after EX/MEM

    wire [31:0] ex_mem_branch_target; // branch target address
    wire [31:0] ex_mem_alu_result;    // ALU result
    wire [31:0] ex_mem_rdata2;        // forwarded rt for stores
    wire [4:0]  ex_mem_write_reg;     // destination register number

    // PC control back to Fetch
    wire        ex_mem_pc_src;        // 1 = take branch, 0 = sequential
    wire [31:0] ex_mem_npc;           // next PC value (branch target)

    //========================================================
    // MEM/WB wires (outputs of mem_stage / MEM_WB)
    //========================================================
    wire [31:0] mem_read_data;        // data read from data memory
    wire [31:0] mem_alu_result_out;   // ALU result forwarded to WB
    wire [4:0]  mem_write_reg_out;    // destination register forwarded to WB
    wire [1:0]  mem_WBControl_out;    // {RegWrite, MemtoReg} into WB stage

    //========================================================
    // WB -> ID feedback (writeback to register file in decode)
    //========================================================
    wire        wb_reg_write;         // RegWrite control back to decode/regfile
    wire [4:0]  wb_write_reg_location;// destination register index
    wire [31:0] mem_wb_write_data;    // actual data written to the regfile

    //========================================================
    // FETCH STAGE (IF)
    //========================================================
    fetch FETCH_STAGE (
        .clk          (clk),
        .rst          (rst),

        // PC select from later stage
        .ex_mem_pc_src(ex_mem_pc_src),    // branch taken?
        .ex_mem_npc   (ex_mem_npc),       // branch target

        // Outputs to Decode (via IF/ID latch inside fetch)
        .if_id_instr  (if_id_instr),
        .if_id_npc    (if_id_npc)
    );

    //========================================================
    // DECODE STAGE (ID)
    //========================================================
    decode DECODE_STAGE (
        .clk                  (clk),
        .rst                  (rst),

        // Feedback from WB stage
        .wb_reg_write         (wb_reg_write),
        .wb_write_reg_location(wb_write_reg_location),
        .mem_wb_write_data    (mem_wb_write_data),

        // IF/ID latch outputs from Fetch
        .if_id_instr          (if_id_instr),
        .if_id_npc            (if_id_npc),

        // ID/EX outputs to Execute stage
        .id_ex_wb             (id_ex_wb),
        .id_ex_mem            (id_ex_mem),
        .id_ex_execute        (id_ex_execute),
        .id_ex_npc            (id_ex_npc),
        .id_ex_readdat1       (id_ex_readdat1),
        .id_ex_readdat2       (id_ex_readdat2),
        .id_ex_sign_ext       (id_ex_sign_ext),
        .id_ex_instr_bits_20_16(id_ex_instr_bits_20_16),
        .id_ex_instr_bits_15_11(id_ex_instr_bits_15_11)
    );

    //========================================================
    // EXECUTE STAGE (EX)
    //========================================================

    // Decode EX control bits from ID/EX latch
    wire        ex_regdst  = id_ex_execute[3];   // choose rd vs rt
    wire [1:0]  ex_alu_op  = id_ex_execute[2:1];
    wire        ex_alusrc  = id_ex_execute[0];   // choose imm vs rdata2

    // MEM control into execute is only {MemRead, MemWrite}
    wire [1:0] ex_ctlm_in = id_ex_mem[1:0];      // {MemRead, MemWrite}

    execute EXEC_STAGE (
        .clk        (clk),

        // Control from ID/EX
        .ctlwb_in   (id_ex_wb),                  // WB control (2 bits)
        .ctlm_in    (ex_ctlm_in),                // {MemRead, MemWrite}

        // Data from ID/EX
        .npc        (id_ex_npc),
        .rdata1     (id_ex_readdat1),
        .rdata2     (id_ex_readdat2),
        .s_extend   (id_ex_sign_ext),

        .instr_2016 (id_ex_instr_bits_20_16),    // rt
        .instr_1511 (id_ex_instr_bits_15_11),    // rd

        // ALU control inputs
        .alu_op     (ex_alu_op),
        .funct      (if_id_instr[5:0]),          // funct field

        // Misc EX control
        .alusrc     (ex_alusrc),
        .regdst     (ex_regdst),

        // Outputs after EX/MEM latch (ex_mem)
        .ctlwb_out      (ex_mem_wb),
        .ctlm_out       (ex_mem_mem),           // {MemRead, MemWrite}
        .adder_out      (ex_mem_branch_target), // branch target
        .alu_result_out (ex_mem_alu_result),
        .rdata2_out     (ex_mem_rdata2),
        .muxout_out     (ex_mem_write_reg)
    );

    //========================================================
    // MEMORY STAGE (MEM) + MEM/WB + PCSrc (mem_stage)
    //========================================================

    // Zero flag computed from ALU result for branches
    wire ex_zero = (ex_mem_alu_result == 32'b0);

    // mem_stage also outputs PCSrc for branch decision
    wire mem_PCSrc;

    mem_stage MEM_STAGE (
        .clk          (clk),
        .ALUResult    (ex_mem_alu_result),    // address for load/store, ALU result for WB
        .WriteData    (ex_mem_rdata2),        // store data (rt)
        .WriteReg     (ex_mem_write_reg),     // dest register
        .WBControl    (ex_mem_wb),            // {RegWrite, MemtoReg}
        .MemWrite     (ex_mem_mem[0]),        // MemWrite bit
        .MemRead      (ex_mem_mem[1]),        // MemRead bit
        .Branch       (id_ex_mem[2]),         // Branch control bit
        .Zero         (ex_zero),              // result == 0 ?

        // Outputs from MEM/WB
        .ReadData     (mem_read_data),
        .ALUResult_out(mem_alu_result_out),
        .WriteReg_out (mem_write_reg_out),
        .WBControl_out(mem_WBControl_out),

        // PCSrc back to Fetch
        .PCSrc        (mem_PCSrc)
    );

    // Connect branch PCSrc + target back into Fetch
    assign ex_mem_npc    = ex_mem_branch_target; // branch target address
    assign ex_mem_pc_src = mem_PCSrc;            // branch decision from MEM

    //========================================================
    // WRITEBACK STAGE (WB)
    //========================================================
    wb_stage WB_STAGE (
        .ReadData      (mem_read_data),        // load data from memory
        .ALUResult     (mem_alu_result_out),   // ALU result (for R-type or address)
        .WriteReg_in   (mem_write_reg_out),    // dest register index
        .WBControl_in  (mem_WBControl_out),    // {RegWrite, MemtoReg}

        .WriteData     (mem_wb_write_data),    // final data written to regfile
        .WriteReg_out  (wb_write_reg_location),
        .RegWrite      (wb_reg_write)
    );

endmodule