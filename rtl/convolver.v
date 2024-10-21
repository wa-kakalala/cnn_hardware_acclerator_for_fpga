`timescale 1ns / 1ps

module convolver # (
    parameter FM_ROW = 9'h00a,     // activation map size
    parameter FM_COL = 9'h00a,
    parameter K      = 9'h003,     // kernel size
    parameter S      = 1           // value of stride (horizontal and vertical stride are equal)
)(
    input                 clk         ,
    input                 rst         ,

    input                 weight_vld  ,
    input  [15:0]         weight      ,

    input                 ce          ,
    input  [15:0]         activation  ,

    output                valid_conv  ,
    output [31:0]         conv_op     ,
    output                end_conv     
);

reg [$clog2(K*K)-1:0] weg_cnt;
always@(posedge clk or posedge rst) begin
    if(rst) begin
        weg_cnt <= 'b0;
    end else if( ce ) begin
        weg_cnt <= 'b0;
    end else if( weight_vld ) begin
        weg_cnt <= weg_cnt + 1'b1;
    end else begin
        weg_cnt <= weg_cnt;
    end
end

reg [15:0] weight_reg [K*K-1:0];

always@(posedge clk or posedge rst) begin
    if( weight_vld ) begin
        weight_reg[weg_cnt] <= weight;
    end
end

wire [31:0] tmp [K*K-1:0];

assign tmp[0] = 32'h0000000;

genvar i;
generate
    for(i = 0;i<K*K;i=i+1) begin: MAC
        if((i+1)%K ==0) begin             // end of the row
            if(i==K*K-1) begin            // end of convolver
                mac_manual mac_inst(      // implements a*b+c
                    .clk (clk             ), // input clk
                    .ce  (ce              ), // input ce
                    .sclr(rst             ), // input sclr
                    .a   (activation      ), // activation input [15 : 0] a
                    .b   (weight_reg[i]   ), // weight input [15 : 0] b
                    .c   (tmp[i]          ), // previous mac sum input [32 : 0] c
                    .p   (conv_op         )  // output [32 : 0] p
                );
            end else begin
                wire [31:0] tmp2;         // make a mac unit
                mac_manual mac_inst(      // implements a*b+c
                    .clk (clk             ), // input clk
                    .ce  (ce              ), // input ce
                    .sclr(rst             ), // input sclr
                    .a   (activation      ), // activation input [15 : 0] a
                    .b   (weight_reg[i]   ), // weight input [15 : 0] b
                    .c   (tmp[i]          ), // previous mac sum input [33 : 0] c
                    .p   (tmp2            )  // output [33 : 0] p
                );
                c_shift_ram  #(              // make a shift register unit
                    .N_DATA (32           ),
                    .N_LEN  (FM_COL-K     )
                )SR(
                    .i_clk  (clk          ),
                    .i_ce   (ce           ),
                    .i_rst_n(!rst         ),
                    .i_data (tmp2         ),
                    .o_data (tmp[i+1]     ) 
                );  
            end
        end else begin
            mac_manual mac_inst(              // implements a*b+c
                .clk       (clk           ),  // input clk
                .ce        (ce            ),  // input ce
                .sclr      (rst           ),  // input sclr
                .a         (activation    ),  // activation input [15 : 0] a
                .b         (weight_reg[i] ),  // weight input [15 : 0] b
                .c         (tmp[i]        ),  // previous mac sum input [31 : 0] c
                .p         (tmp[i+1]      )   // output [31 : 0] p
            );
        end
    end
endgenerate

// output logic 
reg [$clog2(( FM_COL * (K-1)) + K )-1:0]                         out_st_cnt    ; // count to when start
reg                                                              out_st_vld    ; // vld for whole output stage
reg [$clog2(FM_COL):0]                                           out_cnt       ; // count to the row
wire                                                             out_vld       ; // vld for the row
reg [$clog2( ((FM_COL-K)/S + 1)  * ( (FM_ROW-K)/S + 1) +1)-1:0]  out_vld_cnt   ;
reg [$clog2(S)-1:0]                                              out_srd_rcnt  ; // stride row cnt
reg [$clog2(S)-1:0]                                              out_srd_ccnt  ; // stride col cnt
wire                                                             out_srd_vld   ;
wire                                                             out_srd_rvld  ;
wire                                                             out_srd_cvld  ;

// when input activation is valid , count it 
always @(posedge clk or posedge rst) begin 
    if( rst ) begin
        out_st_cnt <= 'b0;
    end else if( weight_vld ) begin 
        out_st_cnt <= 'b0;
    end else if( ce ) begin
        out_st_cnt <= out_st_cnt + 1'b1;
    end else begin
        out_st_cnt <= out_st_cnt;
    end
end

// enable output data 
wire out_st_vld_en;
wire out_st_vld_end;
assign out_st_en = (out_st_cnt == ( ( FM_COL* (K-1)) + K -1 ) ) ? 1'b1: 1'b0;
assign out_st_vld_end = (out_vld_cnt == ( (FM_COL-K)/S + 1 ) * ( (FM_ROW-K)/S + 1 )) ? 1'b1:1'b0;
always @(posedge clk or posedge rst ) begin 
    if( rst ) begin 
        out_st_vld <= 1'b0;
    end else if( out_st_en ) begin 
        out_st_vld <= 1'b1;
    end else if( out_st_vld_end ) begin 
        out_st_vld <= 1'b0;
    end else begin 
        out_st_vld <= out_st_vld;
    end
end 

// count for every row
wire   out_cnt_row_end ;
assign out_cnt_row_end = (out_cnt == ( FM_COL -1))?1'b1:1'b0;
assign out_vld         = (out_st_vld && (out_cnt < (FM_COL-K+1)))?1'b1:1'b0;
always @(posedge clk or posedge rst) begin 
    if( rst ) begin
        out_cnt <= 'b0;
    end else if( out_st_vld ) begin 
        if( out_cnt_row_end ) begin 
            out_cnt <= 'b0;
        end else begin 
            out_cnt <= out_cnt + 1'b1;
        end
    end else begin
        out_cnt <= 'b0;
    end
end

// stride row cnt 
always @(posedge clk or posedge rst) begin
    if( rst ) begin 
        out_srd_rcnt <= 'b0;
    end else if( out_st_vld ) begin 
        if( (out_srd_rcnt == S-1) &&  out_cnt_row_end ) begin 
            out_srd_rcnt <= 'b0;
        end else if( out_cnt_row_end ) begin 
            out_srd_rcnt <= out_srd_rcnt + 1'b1 ;
        end else begin 
            out_srd_rcnt <= out_srd_rcnt;
        end
    end else begin 
        out_srd_rcnt <= 'b0;
    end
end 

// stride col cnt 
always @(posedge clk or posedge rst) begin
    if( rst ) begin 
        out_srd_ccnt <= 'b0;
    end else if( out_vld ) begin 
        if( (out_srd_ccnt == S-1) ) begin 
            out_srd_ccnt <= 'b0;
        end else begin 
            out_srd_ccnt <= out_srd_ccnt + 1'b1 ;
        end
    end else begin 
        out_srd_ccnt <= 'b0;
    end
end 

assign out_srd_rvld = (out_srd_rcnt == 'b0)? 1'b1:1'b0;
assign out_srd_cvld = (out_srd_ccnt == 'b0)? 1'b1:1'b0;

assign out_srd_vld  = out_srd_rvld & out_srd_cvld & out_vld;


// total valid data num 
// feature map : R X C 
// kernel      : N X N 
// stride      : S
// output      : ( R - N )/S + 1, (C - N )/S + 1
always @(posedge clk or posedge rst) begin
    if( rst ) begin 
        out_vld_cnt <= 'b0;
    end else if( out_st_vld ) begin 
        if( out_srd_vld ) begin
            out_vld_cnt <= out_vld_cnt + 1'b1;
        end else begin 
            out_vld_cnt <= out_vld_cnt;
        end
    end else begin 
        out_vld_cnt <= 'b0;
    end
end

assign valid_conv = out_srd_vld ? 1'b1:1'b0 ;
assign end_conv   = ((out_vld_cnt == ( (FM_COL-K)/S + 1 ) * ( (FM_ROW-K)/S + 1 ) -1'b1 ) && out_srd_vld) ? 1'b1:1'b0;
endmodule
