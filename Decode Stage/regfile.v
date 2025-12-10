`timescale 1ns / 1ps

module regFile(
    input  wire        clk,
    input  wire        rst,
    input  wire        regwrite,
    input  wire [4:0]  rs,
    input  wire [4:0]  rt,
    input  wire [4:0]  rd,
    input  wire [31:0] writedata,
    output wire [31:0] A_readdat1,
    output wire [31:0] B_readdat2
);

    reg [31:0] REG [0:31];
    integer i;

    // ------------------------------------------------
    // Initialize registers (prof's values + clear rest)
    // ------------------------------------------------
    initial begin
        // default everything to 0 to avoid X
        for (i = 0; i < 32; i = i + 1) begin
            REG[i] = 32'b0;
        end

        REG[0] = 32'h002300AA;
        REG[1] = 32'h10654321;
        REG[2] = 32'h00100022;
        REG[3] = 32'h8C123456;
        REG[4] = 32'h8F123456;
        REG[5] = 32'hAD654321;
        REG[6] = 32'h60000066;
        REG[7] = 32'h13012345;
        REG[8] = 32'hAC654321;
        REG[9] = 32'h12012345;
    end

    // ------------------------------------------------
    // Synchronous write (on WB stage)
    // ------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, you can either re-load the initial contents
            // or just clear everything. For sim clarity:
            for (i = 0; i < 32; i = i + 1) begin
                REG[i] <= REG[i];  // no change, keep initial pattern
            end
        end else begin
            if (regwrite && (rd != 5'd0)) begin
                REG[rd] <= writedata;
            end
            // always enforce $zero = 0
            REG[0] <= 32'b0;
        end
    end

    // ------------------------------------------------
    // Asynchronous reads (no clock, no regwrite gating)
    // ------------------------------------------------
    assign A_readdat1 = REG[rs];
    assign B_readdat2 = REG[rt];

endmodule
