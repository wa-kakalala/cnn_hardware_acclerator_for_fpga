`timescale 1ns / 1ps
module mac_manual(
    input             clk   ,
    input             sclr  ,
    input             ce    ,
    input [15:0]      a     ,
    input [15:0]      b     ,
    input [31:0]      c     , 
    output reg [31:0] p
);

wire [31:0] sum;
wire [31:0] m;

qmult #(8,16)  mul(a,b,m);
qadd  #(16,32) add(m,c,sum);

always @ (posedge clk,posedge sclr) begin
    if(sclr) begin
        p<=0;
    end else if(ce) begin
        p <= sum;
    end
 end
endmodule