/**************************************
@ filename    : pooler.sv
@ author      : yyrwkk
@ create time : 2024/11/04 22:32:02
@ version     : v1.0.0
**************************************/
`timescale 1ns / 1ps

module maxpooler #(
    parameter FM_ROW = 9'h00c ,
    parameter FM_COL = 9'h00c ,
    parameter P      = 9'h003 ,
    parameter N_DATA = 32   
)(
    input               clk          ,
    input               rst          ,
    input               data_in_vld  ,
    input  [N_DATA-1:0] data_in      ,
    output [N_DATA-1:0] data_out     ,
    output              data_out_vld ,
    output              data_out_end     
);

reg [$clog2(P) -1:0]        pool_c_cnt ;
reg [$clog2(P) -1:0]        pool_r_cnt ;
reg [$clog2(FM_COL/P) -1:0] pool_cn_cnt;
reg [$clog2(FM_ROW/P) -1:0] pool_rn_cnt;

wire tile_col_end ;
wire col_end      ;
wire tile_row_end ;
wire row_end      ;

assign tile_col_end = (pool_c_cnt == P-1) ? 1'b1 : 1'b0;
always@(posedge clk or posedge rst ) begin 
    if( rst ) begin 
        pool_c_cnt <= 'b0;
    end else begin
        if( data_in_vld == 1'b1 ) begin 
            if(  tile_col_end  ) begin   // and every row end 
                pool_c_cnt <= 1'b0;
            end else begin 
                pool_c_cnt <= pool_c_cnt + 1'b1;
            end
        end else begin 
            pool_c_cnt <= pool_c_cnt;
        end
    end
end

assign col_end =  (pool_cn_cnt == FM_COL/P -1'b1) ? 1'b1 : 1'b0;
always@(posedge clk or posedge rst ) begin 
    if( rst ) begin 
        pool_cn_cnt <= 'b0;
    end else begin 
        if( tile_col_end ) begin 
            if(  col_end ) begin 
                pool_cn_cnt <= 'b0;
            end else begin 
                pool_cn_cnt <= pool_cn_cnt + 1'b1;
            end
        end else begin 
            pool_cn_cnt <= pool_cn_cnt;
        end
    end
end

assign tile_row_end = (pool_r_cnt == P -1'b1) ? 1'b1:1'b0;
always@(posedge clk or posedge rst ) begin 
    if( rst ) begin 
        pool_r_cnt <= 'b0;
    end else begin 
        if( tile_col_end & col_end ) begin 
            if( tile_row_end ) begin 
                pool_r_cnt <= 'b0;
            end else begin 
                pool_r_cnt <= pool_r_cnt + 1'b1;
            end
        end else begin 
            pool_r_cnt <= pool_r_cnt;
        end
    end
end

assign row_end = (pool_rn_cnt == FM_ROW/P -1) ? 1'b1:1'b0;
always@(posedge clk or posedge rst ) begin
    if( rst ) begin 
        pool_rn_cnt <= 'b0;
    end else begin 
        if( tile_col_end & col_end & tile_row_end ) begin 
            if( row_end  ) begin 
                pool_rn_cnt <= 'b0;
            end else begin 
                pool_rn_cnt <= pool_rn_cnt + 1'b1;
            end
        end else begin 
            pool_rn_cnt <= pool_rn_cnt;
        end
    end
end

wire [N_DATA-1:0] c_shift_max    ; 

wire [N_DATA-1:0] max2in_max     ;
reg  [N_DATA-1:0] max2in_max_reg ;

always @( posedge clk or posedge rst ) begin 
    if( rst ) begin 
        max2in_max_reg <= 'b0;
    end else begin 
        if( data_in_vld ) begin 
            max2in_max_reg <= max2in_max;
        end else begin 
            max2in_max_reg <= max2in_max_reg;
        end
    end
end

wire [N_DATA-1:0] shift_in_data ;
assign shift_in_data = ( tile_col_end ) 
                       ? 
                       (tile_row_end ? 'b0: max2in_max )
                       :
                       'b0;



max2in # (
    .N_DATA ( 32 )
) max2pin_inst (    
    .ip1    (data_in      ),
    .ip2    (c_shift_max  ),
    .comp_op(max2in_max   )
);

c_shift_ram # (
    .N_DATA   (   32   ),
    .N_LEN    (FM_COL/P) 
)c_shift_ram_inst(
    .i_clk    (clk           ),
    .i_rst_n  (!rst          ),
    .i_ce     (tile_col_end  ),
    .i_data   (shift_in_data ),
    .o_data   (c_shift_max   )
);

reg [N_DATA-1:0] maxpool_data;
reg              maxpool_vld ;
reg              maxpool_end ;

always @( posedge clk or posedge rst ) begin 
    if( rst ) begin 
        maxpool_data <= 'b0;
        maxpool_vld  <= 1'b0;
    end else begin 
        if( tile_row_end & tile_col_end) begin 
            maxpool_data <= max2in_max;
            maxpool_vld  <= 1'b1;
        end else begin 
            maxpool_data <= 'b0;
            maxpool_vld  <= 1'b0;
        end
    end
end

always @( posedge clk or posedge rst ) begin 
    if( rst ) begin 
        maxpool_end <= 1'b0;
    end else begin 
        if( tile_col_end & col_end & tile_row_end & row_end ) begin 
            maxpool_end <= 1'b1;
        end else begin 
            maxpool_end <= 1'b0;
        end
    end
end

assign data_out     = maxpool_data;
assign data_out_vld = maxpool_vld ;
assign data_out_end = maxpool_end ;

endmodule
