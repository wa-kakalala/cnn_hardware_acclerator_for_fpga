/**************************************
@ filename    : tb_maxpooler.sv
@ author      : yyrwkk
@ create time : 2024/11/05 14:44:24
@ version     : v1.0.0
**************************************/
`timescale 1ns/1ns
module tb_maxpooler();

parameter N_DATA = 32;

logic              clk         ;
logic              rst         ;
logic              data_in_vld ;
logic [N_DATA-1:0] data_in     ;
logic [N_DATA-1:0] data_out    ;
logic              data_out_vld;
logic              data_out_end;

maxpooler # (
    .FM_ROW (12 ),
    .FM_COL (12 ),
    .P      (4  ),
    .N_DATA (32 )  
)maxpooler_inst(
    .clk         (clk         ) ,
    .rst         (rst         ) ,
    .data_in_vld (data_in_vld ) ,
    .data_in     (data_in     ) ,
    .data_out    (data_out    ) ,
    .data_out_vld(data_out_vld) ,
    .data_out_end(data_out_end)     
);

initial begin 
    clk         = 'b0;
    rst         = 'b1;
    data_in_vld = 'b0;
    data_in     = 'b0;
end 

initial begin 
    forever #5 clk = ~clk;
end 

initial begin 
    @( posedge clk );
    rst <= 1'b0;
    @(posedge clk);

    for( int i=0;i<144;i++) begin 
        data_in_vld <= 1'b1;
        data_in     <= i+1;
        @(posedge clk);
    end
    data_in_vld <= 'b0;
    data_in     <= 'b0;

    repeat(10) @(posedge clk);
    $stop;
end






endmodule