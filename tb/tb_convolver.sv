/**************************************
@ filename    : tb_convolver.sv
@ author      : yyrwkk
@ create time : 2024/10/18 12:29:50
@ version     : v1.0.0
**************************************/
`timescale 1ns / 1ps
module tb_convolver();

logic                clk         ;
logic                rst         ;
logic                weight_vld  ;
logic [15:0]         weight      ;
logic                ce          ;
logic [15:0]         activation  ;
logic                valid_conv  ;
logic [31:0]         conv_op     ;
logic                end_conv    ; 
 
convolver # (  
    .FM_ROW (10),     // activation map size
    .FM_COL (10), 
    .K      (3 ),     // kernel size
    .S      (1 )      // value of stride (horizontal and vertical stride are equal)
)convolver_inst(
    .clk         (clk         ),
    .rst         (rst         ),
    .weight_vld  (weight_vld  ),
    .weight      (weight      ),
    .ce          (ce          ),
    .activation  (activation  ),
    .valid_conv  (valid_conv  ),
    .conv_op     (conv_op     ),
    .end_conv    (end_conv    ) 
);

initial begin
    clk         = 'b0;
    rst  = 'b1;
    weight_vld= 'b0;
    weight    = 'b0;
    ce          = 'b0;
    activation  = 'b0;
end

initial begin
    forever #5 clk = ~clk;
end

bit [15:0] weight_data [] = '{
    1, 2, 3,
    4, 5, 6,
    7, 8, 9
};
bit [15:0] feature_data[$];
initial begin 
    for( int i=0;i<100;i++) begin 
        feature_data.push_back(i+1);
    end
end

initial begin
    @(posedge clk);
    rst <= 1'b0;
    @(posedge clk);

    for( int i=0;i<9;i++) begin 
        weight_vld <= 1'b1;
        weight     <= weight_data[i];
        @(posedge clk);
    end
    weight_vld <= 1'b0;
    for( int i=0;i<100;i++) begin 
        ce        <= 1'b1;    
        activation<= feature_data[i];
        @(posedge clk);
    end
    ce        <= 1'b0;    

    repeat(200) @(posedge clk);
    $stop; 
end

endmodule