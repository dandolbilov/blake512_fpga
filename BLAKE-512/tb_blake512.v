///////////////////////////////////////////////////////////////////////////////
//
// File:    tb_blake512.v
// Author:  Daniil Dolbilov
// Created: 2017/10/29
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_blake512;

    initial
    begin
        $monitor($stime,, "clk:%h", clk,, "new:%h", new_in,, "round:%h", b512.round,, "state:%h", state,,
                            //"msg0:%h", b512.msg0,, "m0:%h", b512.m0,, "v0:%h", b512.v0,, "v0y:%h", b512.v0y,,
                            "hash:%h", hash);
        $dumpfile("out/tb_blake512.vcd");
        $dumpvars(0, tb_blake512);
        #100; // #220;
        $finish;
    end

    always
    begin
        #1 clk = ~clk;
    end

    reg clk;
    reg new_in;
    reg  [639:0] data;
    wire [511:0] hash;
    wire   [3:0] state;

    blake512_hash b512(
        .clk(clk),
        .new_in(new_in),
        .data_in(data),
        .hash_out(hash),
        .state(state)
    );

    initial
    begin
        clk = 0;
        new_in = 0;
        #2
        data = 640'h00000020B7F3F008AAFA9C96F2018962C5B78E7EE7C1FCCF0F7D4A3152791F00000000001AAE195A7426F1A4D7165F5DFD5765E6602F94B5EDE3988C815E79B518FBBA48A1D74F5A3F6F321B0001AEA0;
        new_in = 1;
        #2
        new_in = 0;
/*
        #110
        data = 640'h77000020B7F3F008AAFA9C96F2018962C5B78E7EE7C1FCCF0F7D4A3152791F00000000001AAE195A7426F1A4D7165F5DFD5765E6602F94B5EDE3988C815E79B518FBBA48A1D74F5A3F6F321B0001AEA0;
        new_in = 1;
        #2
        new_in = 0;
*/
    end

endmodule
