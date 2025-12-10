`timescale 1ns / 1ps

// Memory stage + MEM/WB latch + branch PCSrc
module mem_stage(
    input  wire        clk,
    input  wire [31:0] ALUResult,
    input  wire [31:0] WriteData,
    input  wire [4:0]  WriteReg,
    input  wire [1:0]  WBControl,
    input  wire        MemWrite,
    input  wire        MemRead,
    input  wire        Branch,
    input  wire        Zero,

    output wire [31:0] ReadData,
    output wire [31:0] ALUResult_out,
    output wire [4:0]  WriteReg_out,
    output wire [1:0]  WBControl_out,
    output wire        PCSrc
);

    wire [31:0] mem_read_data;

    // Data memory
    d_mem dmem_inst (
        .clk       (clk),
        .Address   (ALUResult),
        .WriteData (WriteData),
        .MemWrite  (MemWrite),
        .MemRead   (MemRead),
        .ReadData  (mem_read_data)
    );

    // Branch decision
    assign PCSrc = Branch & Zero;

    // MEM/WB pipeline register
    MEM_WB memwb_inst (
        .clk     (clk),
        .alu_in  (ALUResult),
        .mem_in  (mem_read_data),
        .reg_in  (WriteReg),
        .wb_in   (WBControl),

        .alu_out (ALUResult_out),
        .mem_out (ReadData),
        .reg_out (WriteReg_out),
        .wb_out  (WBControl_out)
    );

endmodule
