///////////////////////////////////////////////////////////////////////////////
//
// File:    tb_blake512_G_func.v
// Author:  Daniil Dolbilov
// Created: 2017/10/28
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_blake512_G_func;

    initial
    begin
        $monitor($stime,, "a:%h", a_out,, "b:%h", b_out,, "c:%h", c_out,, "d:%h", d_out);
        $dumpfile("out/tb_blake512_G_func.vcd");
        $dumpvars(0, tb_blake512_G_func);
        #100;
        $finish;
    end

    wire [63:0] a, b, c, d;
    wire [63:0] msg_j, msg_k, C64_j, C64_k;
    wire [63:0] a_out, b_out, c_out, d_out;

    assign a = 64'h6a09e667f3bcc908;
    assign b = 64'h510e527fade682d1;
    assign c = 64'h243f6a8885a308d3;
    assign d = 64'h452821e638d011f7;
    assign msg_j = 64'h00000020b7f3f008;
    assign msg_k = 64'haafa9c96f2018962;
    assign C64_j = 64'h243f6a8885a308d3;
    assign C64_k = 64'h13198a2e03707344;

    blake512_G_func g0(
        a, b, c, d,
        msg_j, msg_k, C64_j, C64_k,
        a_out, b_out, c_out, d_out
    );

    // === expect (step 1, internal) ===
    // a1 = 0xce31c2f65626cf25, b1 = 0xad3499611c0d925e
    // c1 = 0x9336495b10bcebe3, d1 = 0x6ef6ded28b19e310

    // === expect (step 2, output) ===
    // a2 = 0x0a2c5275e9d6e334, b2 = 0x9d87cdc6ea902d3b
    // c2 = 0x935aae359d644eb2, d2 = 0x002464da8ca762cf

endmodule
