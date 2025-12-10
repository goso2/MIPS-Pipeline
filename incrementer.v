`timescale 1ns/1ps
// Incrementer: produces pc+4 (no state inside)
module incrementer (
  input  wire [31:0] pcin,
  output wire [31:0] pcout
);
  assign pcout = pcin + 32'd4;
endmodule
