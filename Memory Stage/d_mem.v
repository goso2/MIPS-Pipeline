`timescale 1ns / 1ps

// Data Memory for MEM stage
module d_mem(
    input  wire        clk,
    input  wire [31:0] Address,    // word address (we use low 8 bits)
    input  wire [31:0] WriteData,
    input  wire        MemWrite,
    input  wire        MemRead,
    output wire [31:0] ReadData
);
    // 256 x 32-bit memory
    reg [31:0] MEM [0:255];

    integer i;

    // Initialize memory contents from data.mem
    initial begin
        $readmemb("data.mem", MEM);
    end

    // Synchronous write
    always @(posedge clk) begin
        if (MemWrite) begin
            MEM[Address[7:0]] <= WriteData;
        end
    end

    // Combinational read
    assign ReadData = MemRead ? MEM[Address[7:0]] : 32'b0;

endmodule
