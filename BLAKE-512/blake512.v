///////////////////////////////////////////////////////////////////////////////
//
// File:    blake512.v
// Author:  Daniil Dolbilov
// Created: 2017/10/29
//
///////////////////////////////////////////////////////////////////////////////

module blake512_hash(
    input  clk,
    input  new_in,
    input      [639:0] data_in,   // partial (80 of 128 bytes)
    output reg [511:0] hash_out,
    output reg   [3:0] state
);

parameter PADDING = 384'h800000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000280;

parameter IV0 = 64'h6A09E667F3BCC908;
parameter IV1 = 64'hBB67AE8584CAA73B;
parameter IV2 = 64'h3C6EF372FE94F82B;
parameter IV3 = 64'hA54FF53A5F1D36F1;
parameter IV4 = 64'h510E527FADE682D1;
parameter IV5 = 64'h9B05688C2B3E6C1F;
parameter IV6 = 64'h1F83D9ABFB41BD6B;
parameter IV7 = 64'h5BE0CD19137E2179;

parameter C0  = 64'h243F6A8885A308D3;
parameter C1  = 64'h13198A2E03707344;
parameter C2  = 64'hA4093822299F31D0;
parameter C3  = 64'h082EFA98EC4E6C89;
parameter C4  = 64'h452821E638D01377;
parameter C5  = 64'hBE5466CF34E90C6C;
parameter C6  = 64'hC0AC29B7C97C50DD;
parameter C7  = 64'h3F84D5B5B5470917;
parameter C8  = 64'h9216D5D98979FB1B;
parameter C9  = 64'hD1310BA698DFB5AC;
parameter C10 = 64'h2FFD72DBD01ADFB7;
parameter C11 = 64'hB8E1AFED6A267E96;
parameter C12 = 64'hBA7C9045F12C7F99;
parameter C13 = 64'h24A19947B3916CF7;
parameter C14 = 64'h0801F2E2858EFC16;
parameter C15 = 64'h636920D871574E69;

///////////////////////////////////////////////////////////////////////////////

reg [63:0] msg0, msg1, msg2, msg3, msg4, msg5, msg6, msg7;
reg [63:0] msg8, msg9, msg10, msg11, msg12, msg13, msg14, msg15;

reg [63:0] v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15;
reg [63:0] m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15;
reg [63:0] c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15;

reg  [3:0] round;

wire [63:0] v0x, v1x, v2x, v3x, v4x, v5x, v6x, v7x, v8x, v9x, v10x, v11x, v12x, v13x, v14x, v15x;
wire [63:0] v0y, v1y, v2y, v3y, v4y, v5y, v6y, v7y, v8y, v9y, v10y, v11y, v12y, v13y, v14y, v15y;

///////////////////////////////////////////////////////////////////////////////

// column step
blake512_G_func g1(v0, v4, v8,  v12, m0, m1, c0, c1, v0x, v4x, v8x,  v12x);
blake512_G_func g2(v1, v5, v9,  v13, m2, m3, c2, c3, v1x, v5x, v9x,  v13x);
blake512_G_func g3(v2, v6, v10, v14, m4, m5, c4, c5, v2x, v6x, v10x, v14x);
blake512_G_func g4(v3, v7, v11, v15, m6, m7, c6, c7, v3x, v7x, v11x, v15x);
// diagonal step
blake512_G_func g5(v0x, v5x, v10x, v15x, m8,  m9,  c8,  c9,  v0y, v5y, v10y, v15y);
blake512_G_func g6(v1x, v6x, v11x, v12x, m10, m11, c10, c11, v1y, v6y, v11y, v12y);
blake512_G_func g7(v2x, v7x, v8x,  v13x, m12, m13, c12, c13, v2y, v7y, v8y,  v13y);
blake512_G_func g8(v3x, v4x, v9x,  v14x, m14, m15, c14, c15, v3y, v4y, v9y,  v14y);

///////////////////////////////////////////////////////////////////////////////
// State Machine
///////////////////////////////////////////////////////////////////////////////

parameter S0 = 4'd0;
parameter S1 = 4'd1;
parameter S2 = 4'd2;
parameter S3 = 4'd3;
parameter S4 = 4'd4;

//   [3:0] state; // place as output
reg  [3:0] nextstate;

initial
begin
    state <= S4;
    nextstate <= S0;
end

always @(posedge clk or negedge clk)
begin
    state <= nextstate;
end

/*
always @(posedge clk or negedge clk)
begin
    case (state)
        S0: nextstate = S1;
        S1: nextstate = S2;
        S2: begin
                if (round < 4'd15) begin
                    nextstate = S1; round = round + 4'd1;
                end
                else begin
                    nextstate = S3;
                end
            end
        S3: nextstate = S4;
        S4: nextstate = S0;
        default: nextstate = S0;
    endcase
end
*/

wire q0; assign q0 = (state == S0);
wire q1; assign q1 = (state == S1);
wire q2; assign q2 = (state == S2);
wire q3; assign q3 = (state == S3);
wire q4; assign q4 = (state == S4);

///////////////////////////////////////////////////////////////////////////////
// state 0: load input data
///////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge clk) begin
    if (new_in && q0)
    begin
        msg0 <= data_in[639:576];
        msg1 <= data_in[575:512];
        msg2 <= data_in[511:448];
        msg3 <= data_in[447:384];
        msg4 <= data_in[383:320];
        msg5 <= data_in[319:256];
        msg6 <= data_in[255:192];
        msg7 <= data_in[191:128];
        msg8 <= data_in[127:64];
        msg9 <= data_in[63:0];
        msg10 <= PADDING[383:320];
        msg11 <= PADDING[319:256];
        msg12 <= PADDING[255:192];
        msg13 <= PADDING[191:128];
        msg14 <= PADDING[127:64];
        msg15 <= PADDING[63:0];
        v0  <= IV0; v1  <= IV1; v2  <= IV2;  v3 <= IV3;
        v4  <= IV4; v5  <= IV5; v6  <= IV6;  v7 <= IV7;
        v8  <= C0;  v9  <= C1;  v10 <= C2;  v11 <= C3;
        v12 <= 64'h452821e638d011f7;  v13 <= 64'hbe5466cf34e90eec; // for 80 bytes
        v14 <= 64'hc0ac29b7c97c50dd;  v15 <= 64'h3f84d5b5b5470917; // for 80 bytes
        round <= 4'd0;
        nextstate <= S1;
    end
end

///////////////////////////////////////////////////////////////////////////////
// state 1: load m0..m15, c0..c15 for next round
///////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge clk) begin
    if (q1)
    begin
        case(round)
            4'd0  :  begin  // round 0
                m0  <= msg0;  m1  <= msg1;  m2  <= msg2;  m3  <= msg3;
                m4  <= msg4;  m5  <= msg5;  m6  <= msg6;  m7  <= msg7;
                m8  <= msg8;  m9  <= msg9;  m10 <= msg10; m11 <= msg11;
                m12 <= msg12; m13 <= msg13; m14 <= msg14; m15 <= msg15;
                c0  <= C0;  c1  <= C1;  c2  <= C2;  c3  <= C3;
                c4  <= C4;  c5  <= C5;  c6  <= C6;  c7  <= C7;
                c8  <= C8;  c9  <= C9;  c10 <= C10; c11 <= C11;
                c12 <= C12; c13 <= C13; c14 <= C14; c15 <= C15;
            end
            4'd1  :  begin  // round 1
                m0  <= msg14; m1  <= msg10; m2  <= msg4;  m3  <= msg8;
                m4  <= msg9;  m5  <= msg15; m6  <= msg13; m7  <= msg6;
                m8  <= msg1;  m9  <= msg12; m10 <= msg0;  m11 <= msg2;
                m12 <= msg11; m13 <= msg7;  m14 <= msg5;  m15 <= msg3;
                c0  <= C14; c1  <= C10; c2  <= C4;  c3  <= C8;
                c4  <= C9;  c5  <= C15; c6  <= C13; c7  <= C6;
                c8  <= C1;  c9  <= C12; c10 <= C0;  c11 <= C2;
                c12 <= C11; c13 <= C7;  c14 <= C5;  c15 <= C3;
            end
            4'd2  :  begin  // round 2
                m0  <= msg11;  m1 <= msg8;  m2 <= msg12;  m3 <= msg0;
                m4  <= msg5;  m5 <= msg2;  m6 <= msg15;  m7 <= msg13;
                m8  <= msg10;  m9 <= msg14;  m10 <= msg3;  m11 <= msg6;
                m12 <= msg7;  m13 <= msg1;  m14 <= msg9;  m15 <= msg4;
                c0  <= C11;  c1 <= C8;  c2 <= C12;  c3 <= C0;
                c4  <= C5;  c5 <= C2;  c6 <= C15;  c7 <= C13;
                c8  <= C10;  c9 <= C14;  c10 <= C3;  c11 <= C6;
                c12 <= C7;  c13 <= C1;  c14 <= C9;  c15 <= C4;
            end
            4'd3  :  begin  // round 3
                m0  <= msg7;  m1 <= msg9;  m2 <= msg3;  m3 <= msg1;
                m4  <= msg13;  m5 <= msg12;  m6 <= msg11;  m7 <= msg14;
                m8  <= msg2;  m9 <= msg6;  m10 <= msg5;  m11 <= msg10;
                m12 <= msg4;  m13 <= msg0;  m14 <= msg15;  m15 <= msg8;
                c0  <= C7;  c1 <= C9;  c2 <= C3;  c3 <= C1;
                c4  <= C13;  c5 <= C12;  c6 <= C11;  c7 <= C14;
                c8  <= C2;  c9 <= C6;  c10 <= C5;  c11 <= C10;
                c12 <= C4;  c13 <= C0;  c14 <= C15;  c15 <= C8;
            end
            4'd4  :  begin  // round 4
                m0  <= msg9;  m1 <= msg0;  m2 <= msg5;  m3 <= msg7;
                m4  <= msg2;  m5 <= msg4;  m6 <= msg10;  m7 <= msg15;
                m8  <= msg14;  m9 <= msg1;  m10 <= msg11;  m11 <= msg12;
                m12 <= msg6;  m13 <= msg8;  m14 <= msg3;  m15 <= msg13;
                c0  <= C9;  c1 <= C0;  c2 <= C5;  c3 <= C7;
                c4  <= C2;  c5 <= C4;  c6 <= C10;  c7 <= C15;
                c8  <= C14;  c9 <= C1;  c10 <= C11;  c11 <= C12;
                c12 <= C6;  c13 <= C8;  c14 <= C3;  c15 <= C13;
            end
            4'd5  :  begin  // round 5
                m0  <= msg2;  m1 <= msg12;  m2 <= msg6;  m3 <= msg10;
                m4  <= msg0;  m5 <= msg11;  m6 <= msg8;  m7 <= msg3;
                m8  <= msg4;  m9 <= msg13;  m10 <= msg7;  m11 <= msg5;
                m12 <= msg15;  m13 <= msg14;  m14 <= msg1;  m15 <= msg9;
                c0  <= C2;  c1 <= C12;  c2 <= C6;  c3 <= C10;
                c4  <= C0;  c5 <= C11;  c6 <= C8;  c7 <= C3;
                c8  <= C4;  c9 <= C13;  c10 <= C7;  c11 <= C5;
                c12 <= C15;  c13 <= C14;  c14 <= C1;  c15 <= C9;
            end
            4'd6  :  begin  // round 6
                m0  <= msg12;  m1 <= msg5;  m2 <= msg1;  m3 <= msg15;
                m4  <= msg14;  m5 <= msg13;  m6 <= msg4;  m7 <= msg10;
                m8  <= msg0;  m9 <= msg7;  m10 <= msg6;  m11 <= msg3;
                m12 <= msg9;  m13 <= msg2;  m14 <= msg8;  m15 <= msg11;
                c0  <= C12;  c1 <= C5;  c2 <= C1;  c3 <= C15;
                c4  <= C14;  c5 <= C13;  c6 <= C4;  c7 <= C10;
                c8  <= C0;  c9 <= C7;  c10 <= C6;  c11 <= C3;
                c12 <= C9;  c13 <= C2;  c14 <= C8;  c15 <= C11;
            end
            4'd7  :  begin  // round 7
                m0  <= msg13;  m1 <= msg11;  m2 <= msg7;  m3 <= msg14;
                m4  <= msg12;  m5 <= msg1;  m6 <= msg3;  m7 <= msg9;
                m8  <= msg5;  m9 <= msg0;  m10 <= msg15;  m11 <= msg4;
                m12 <= msg8;  m13 <= msg6;  m14 <= msg2;  m15 <= msg10;
                c0  <= C13;  c1 <= C11;  c2 <= C7;  c3 <= C14;
                c4  <= C12;  c5 <= C1;  c6 <= C3;  c7 <= C9;
                c8  <= C5;  c9 <= C0;  c10 <= C15;  c11 <= C4;
                c12 <= C8;  c13 <= C6;  c14 <= C2;  c15 <= C10;
            end
            4'd8  :  begin  // round 8
                m0  <= msg6;  m1 <= msg15;  m2 <= msg14;  m3 <= msg9;
                m4  <= msg11;  m5 <= msg3;  m6 <= msg0;  m7 <= msg8;
                m8  <= msg12;  m9 <= msg2;  m10 <= msg13;  m11 <= msg7;
                m12 <= msg1;  m13 <= msg4;  m14 <= msg10;  m15 <= msg5;
                c0  <= C6;  c1 <= C15;  c2 <= C14;  c3 <= C9;
                c4  <= C11;  c5 <= C3;  c6 <= C0;  c7 <= C8;
                c8  <= C12;  c9 <= C2;  c10 <= C13;  c11 <= C7;
                c12 <= C1;  c13 <= C4;  c14 <= C10;  c15 <= C5;
            end
            4'd9  :  begin  // round 9
                m0  <= msg10;  m1 <= msg2;  m2 <= msg8;  m3 <= msg4;
                m4  <= msg7;  m5 <= msg6;  m6 <= msg1;  m7 <= msg5;
                m8  <= msg15;  m9 <= msg11;  m10 <= msg9;  m11 <= msg14;
                m12 <= msg3;  m13 <= msg12;  m14 <= msg13;  m15 <= msg0;
                c0  <= C10;  c1 <= C2;  c2 <= C8;  c3 <= C4;
                c4  <= C7;  c5 <= C6;  c6 <= C1;  c7 <= C5;
                c8  <= C15;  c9 <= C11;  c10 <= C9;  c11 <= C14;
                c12 <= C3;  c13 <= C12;  c14 <= C13;  c15 <= C0;
            end
            4'd10 :  begin  // round 10
                m0  <= msg0;  m1 <= msg1;  m2 <= msg2;  m3 <= msg3;
                m4  <= msg4;  m5 <= msg5;  m6 <= msg6;  m7 <= msg7;
                m8  <= msg8;  m9 <= msg9;  m10 <= msg10;  m11 <= msg11;
                m12 <= msg12;  m13 <= msg13;  m14 <= msg14;  m15 <= msg15;
                c0  <= C0;  c1 <= C1;  c2 <= C2;  c3 <= C3;
                c4  <= C4;  c5 <= C5;  c6 <= C6;  c7 <= C7;
                c8  <= C8;  c9 <= C9;  c10 <= C10;  c11 <= C11;
                c12 <= C12;  c13 <= C13;  c14 <= C14;  c15 <= C15;
            end
            4'd11 :  begin  // round 11
                m0  <= msg14;  m1 <= msg10;  m2 <= msg4;  m3 <= msg8;
                m4  <= msg9;  m5 <= msg15;  m6 <= msg13;  m7 <= msg6;
                m8  <= msg1;  m9 <= msg12;  m10 <= msg0;  m11 <= msg2;
                m12 <= msg11;  m13 <= msg7;  m14 <= msg5;  m15 <= msg3;
                c0  <= C14;  c1 <= C10;  c2 <= C4;  c3 <= C8;
                c4  <= C9;  c5 <= C15;  c6 <= C13;  c7 <= C6;
                c8  <= C1;  c9 <= C12;  c10 <= C0;  c11 <= C2;
                c12 <= C11;  c13 <= C7;  c14 <= C5;  c15 <= C3;
            end
            4'd12 :  begin  // round 12
                m0  <= msg11;  m1 <= msg8;  m2 <= msg12;  m3 <= msg0;
                m4  <= msg5;  m5 <= msg2;  m6 <= msg15;  m7 <= msg13;
                m8  <= msg10;  m9 <= msg14;  m10 <= msg3;  m11 <= msg6;
                m12 <= msg7;  m13 <= msg1;  m14 <= msg9;  m15 <= msg4;
                c0  <= C11;  c1 <= C8;  c2 <= C12;  c3 <= C0;
                c4  <= C5;  c5 <= C2;  c6 <= C15;  c7 <= C13;
                c8  <= C10;  c9 <= C14;  c10 <= C3;  c11 <= C6;
                c12 <= C7;  c13 <= C1;  c14 <= C9;  c15 <= C4;
            end
            4'd13 :  begin  // round 13
                m0  <= msg7;  m1 <= msg9;  m2 <= msg3;  m3 <= msg1;
                m4  <= msg13;  m5 <= msg12;  m6 <= msg11;  m7 <= msg14;
                m8  <= msg2;  m9 <= msg6;  m10 <= msg5;  m11 <= msg10;
                m12 <= msg4;  m13 <= msg0;  m14 <= msg15;  m15 <= msg8;
                c0  <= C7;  c1 <= C9;  c2 <= C3;  c3 <= C1;
                c4  <= C13;  c5 <= C12;  c6 <= C11;  c7 <= C14;
                c8  <= C2;  c9 <= C6;  c10 <= C5;  c11 <= C10;
                c12 <= C4;  c13 <= C0;  c14 <= C15;  c15 <= C8;
            end
            4'd14 :  begin  // round 14
                m0  <= msg9;  m1 <= msg0;  m2 <= msg5;  m3 <= msg7;
                m4  <= msg2;  m5 <= msg4;  m6 <= msg10;  m7 <= msg15;
                m8  <= msg14;  m9 <= msg1;  m10 <= msg11;  m11 <= msg12;
                m12 <= msg6;  m13 <= msg8;  m14 <= msg3;  m15 <= msg13;
                c0  <= C9;  c1 <= C0;  c2 <= C5;  c3 <= C7;
                c4  <= C2;  c5 <= C4;  c6 <= C10;  c7 <= C15;
                c8  <= C14;  c9 <= C1;  c10 <= C11;  c11 <= C12;
                c12 <= C6;  c13 <= C8;  c14 <= C3;  c15 <= C13;
            end
            4'd15 :  begin  // round 15
                m0  <= msg2;  m1 <= msg12;  m2 <= msg6;  m3 <= msg10;
                m4  <= msg0;  m5 <= msg11;  m6 <= msg8;  m7 <= msg3;
                m8  <= msg4;  m9 <= msg13;  m10 <= msg7;  m11 <= msg5;
                m12 <= msg15;  m13 <= msg14;  m14 <= msg1;  m15 <= msg9;
                c0  <= C2;  c1 <= C12;  c2 <= C6;  c3 <= C10;
                c4  <= C0;  c5 <= C11;  c6 <= C8;  c7 <= C3;
                c8  <= C4;  c9 <= C13;  c10 <= C7;  c11 <= C5;
                c12 <= C15;  c13 <= C14;  c14 <= C1;  c15 <= C9;
            end
        endcase
        nextstate <= S2;
    end
end

///////////////////////////////////////////////////////////////////////////////
// state 2: get hash (on each round)
///////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge clk) begin
    if (q2)
    begin
        hash_out[511:448] <= IV0 ^ v0y ^ v8y;
        hash_out[447:384] <= IV1 ^ v1y ^ v9y;
        hash_out[383:320] <= IV2 ^ v2y ^ v10y;
        hash_out[319:256] <= IV3 ^ v3y ^ v11y;
        hash_out[255:192] <= IV4 ^ v4y ^ v12y;
        hash_out[191:128] <= IV5 ^ v5y ^ v13y;
        hash_out[127:64]  <= IV6 ^ v6y ^ v14y;
        hash_out[63:0]    <= IV7 ^ v7y ^ v15y;

        nextstate <= S3;
    end
end

///////////////////////////////////////////////////////////////////////////////
// state 3: update v0..v15, increment round
///////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge clk) begin
    if (clk && q3)
    begin
        v0 <= v0y;   v1 <= v1y;   v2 <= v2y;   v3 <= v3y;
        v4 <= v4y;   v5 <= v5y;   v6 <= v6y;   v7 <= v7y;
        v8 <= v8y;   v9 <= v9y;   v10 <= v10y; v11 <= v11y;
        v12 <= v12y; v13 <= v13y; v14 <= v14y; v15 <= v15y;

        if (round < 4'd15)
        begin
            round <= round + 4'd1;
            nextstate <= S1;
        end
        else
        begin
            nextstate <= S4;
        end
    end
end

///////////////////////////////////////////////////////////////////////////////
// state 4: 
///////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge clk) begin
    if (q4)
    begin
        nextstate <= S0;
    end
end


endmodule
