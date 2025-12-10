`timescale 1ns / 1ps

// 32-bit 2:1 multiplexer
// sel = 0 → y = d0
// sel = 1 → y = d1
module mux2to1_32(
    input  wire [31:0] d0,
    input  wire [31:0] d1,
    input  wire        sel,
    output wire [31:0] y
);
    assign y = sel ? d1 : d0;
endmodule
