`timescale 1ns / 1ps

module memoryTB();
    reg clk;
    reg [31:0] ALUResult, WriteData;
    reg [4:0]  WriteReg;
    reg [1:0]  WBControl;
    reg        MemWrite, MemRead, Branch, Zero;

    wire [31:0] ReadData, ALUResult_out;
    wire [4:0]  WriteReg_out;
    wire [1:0]  WBControl_out;
    wire        PCSrc;

    mem_stage uut (
        .clk(clk),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .WriteReg(WriteReg),
        .WBControl(WBControl),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .Branch(Branch),
        .Zero(Zero),
        .ReadData(ReadData),
        .ALUResult_out(ALUResult_out),
        .WriteReg_out(WriteReg_out),
        .WBControl_out(WBControl_out),
        .PCSrc(PCSrc)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 10 ns period
    end

    initial begin
        // Initial values
        ALUResult = 32'h00000004;   // address = 4
        WriteData = 32'h12345678;
        WriteReg  = 5'h02;
        WBControl = 2'b01;
        MemWrite  = 0;
        MemRead   = 1;
        Branch    = 0;
        Zero      = 0;

        // First: memory read
        #10;

        // Memory write at same address
        MemWrite = 1;
        MemRead  = 0;
        #10;

        // Read back written value
        MemWrite = 0;
        MemRead  = 1;
        #10;

        // Branch test
        Branch = 1;
        Zero   = 1;
        #10;

        $finish;
    end
endmodule
