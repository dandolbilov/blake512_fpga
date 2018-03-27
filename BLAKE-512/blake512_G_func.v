///////////////////////////////////////////////////////////////////////////////
//
// File:    blake512_G_func.v
// Author:  Daniil Dolbilov
// Created: 2017/10/28
//
///////////////////////////////////////////////////////////////////////////////

module blake512_G_func(
    input  [63:0] a, b, c, d,
    input  [63:0] msg_j, msg_k, C64_j, C64_k,
    output [63:0] a_out, b_out, c_out, d_out
);
    wire [63:0] a1, b1, c1, d1;
    wire [63:0] d1x, b1x;
    wire [63:0] d2x, b2x;

    // step 1
    assign a1 = a + b + (msg_j ^ C64_k);
    assign d1x = d ^ a1;
    assign d1 = {d1x[31:0], d1x[63:32]}; // shift 32
    assign c1 = c + d1;
    assign b1x = b ^ c1;
    assign b1 = {b1x[24:0], b1x[63:25]}; // shift 25

    // step 2
    assign a_out = a1 + b1 + (msg_k ^ C64_j);
    assign d2x = d1 ^ a_out;
    assign d_out = {d2x[15:0], d2x[63:16]}; // shift 16
    assign c_out = c1 + d_out;
    assign b2x = b1 ^ c_out;
    assign b_out = {b2x[10:0], b2x[63:11]}; // shift 11

endmodule
