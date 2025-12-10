`timescale 1ns / 1ps

// MEM/WB pipeline register
module MEM_WB(
    input  wire        clk,
    input  wire [31:0] alu_in,
    input  wire [31:0] mem_in,
    input  wire [4:0]  reg_in,
    input  wire [1:0]  wb_in,

    output reg  [31:0] alu_out,
    output reg  [31:0] mem_out,
    output reg  [4:0]  reg_out,
    output reg  [1:0]  wb_out
);

    always @(posedge clk) begin
        alu_out <= alu_in;
        mem_out <= mem_in;
        reg_out <= reg_in;
        wb_out  <= wb_in;
    end

endmodule
