/**************************************
@ filename    : comparator2in.v
@ author      : yyrwkk
@ create time : 2024/11/04 22:35:47
@ version     : v1.0.0
**************************************/
module max2in #(
    parameter N_DATA = 32    
)(
    input  [N_DATA-1:0]  ip1    ,
    input  [N_DATA-1:0]  ip2    ,
    output [N_DATA-1:0]  comp_op  
);

assign comp_op = ( ip1 > ip2 )
                 ?
                 ip1
                 :
                 ip2;
endmodule 