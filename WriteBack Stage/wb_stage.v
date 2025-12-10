`timescale 1ns / 1ps

//==============================
// Writeback (WB) Stage
//==============================
// Inputs come from MEM/WB pipeline register.
// WBControl_in = {RegWrite, MemtoReg}
//==============================

module wb_stage(
    input  wire [31:0] ReadData,       // load data from memory
    input  wire [31:0] ALUResult,      // ALU output
    input  wire [4:0]  WriteReg_in,    // destination register #
    input  wire [1:0]  WBControl_in,   // {RegWrite, MemtoReg}

    output wire [31:0] WriteData,      // final data written to register file
    output wire [4:0]  WriteReg_out,   // forwarded write register
    output wire        RegWrite        // write enable for register file
);

    // Extract control bits
    wire RegWrite_bit = WBControl_in[1];
    wire MemtoReg     = WBControl_in[0];

    assign RegWrite    = RegWrite_bit;
    assign WriteReg_out = WriteReg_in;

    // mux selects:
    //   MemtoReg = 0 → ALUResult 
    //   MemtoReg = 1 → ReadData  
    mux2to1_32 wb_mux (
        .d0(ALUResult),
        .d1(ReadData),
        .sel(MemtoReg),
        .y(WriteData)
    );

endmodule
