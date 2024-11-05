/**************************************
@ filename    : c_shift_ram.v
@ author      : yyrwkk
@ create time : 2024/10/18 11:52:56
@ version     : v1.0.0
**************************************/
module c_shift_ram # (
    parameter N_DATA = 32,
    parameter N_LEN  = 29 
)(
    input              i_clk    ,
    input              i_rst_n  ,
    input              i_ce     ,
    input [N_DATA-1:0] i_data   ,

    output[N_DATA-1:0] o_data   
);

reg [N_DATA-1:0] shift_reg [N_LEN-1:0];

genvar i;
generate
    for(i=0;i<N_LEN;i=i+1) begin : shift_block
        if( i==0 ) begin
            always @(posedge i_clk or negedge i_rst_n ) begin
                if( ! i_rst_n ) begin
                    shift_reg[0] <= 'b0;
                end else if( i_ce ) begin
                    shift_reg[0] <= i_data;
                end else begin
                    shift_reg[0] <= shift_reg[0];
                end
            end
        end else begin
            always @(posedge i_clk or negedge i_rst_n ) begin
                if( ! i_rst_n ) begin
                    shift_reg[i] <= 'b0;
                end else if( i_ce )begin
                    shift_reg[i] <= shift_reg[i-1];
                end else begin
                    shift_reg[i] <= shift_reg[i];
                end
            end
        end
    end
endgenerate

assign o_data = (i_ce) ? shift_reg [N_LEN-1] : 'b0;

endmodule