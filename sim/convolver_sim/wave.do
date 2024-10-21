onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group top -radix unsigned /tb_convolver/activation
add wave -noupdate -expand -group top /tb_convolver/ce
add wave -noupdate -expand -group top /tb_convolver/clk
add wave -noupdate -expand -group top -radix unsigned /tb_convolver/conv_op
add wave -noupdate -expand -group top /tb_convolver/end_conv
add wave -noupdate -expand -group top -color Magenta /tb_convolver/valid_conv
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/activation
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/ce
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/clk
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/conv_op
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/end_conv
add wave -noupdate -expand -group convolver -radix unsigned /tb_convolver/convolver_inst/out_st_cnt
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/out_st_vld
add wave -noupdate -expand -group convolver -radix unsigned /tb_convolver/convolver_inst/out_vld_cnt
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/tmp
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/valid_conv
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/weg_cnt
add wave -noupdate -expand -group convolver /tb_convolver/convolver_inst/weight
add wave -noupdate /tb_convolver/convolver_inst/out_srd_ccnt
add wave -noupdate /tb_convolver/convolver_inst/out_srd_cvld
add wave -noupdate -color Magenta /tb_convolver/convolver_inst/out_srd_rcnt
add wave -noupdate -color Magenta /tb_convolver/convolver_inst/out_srd_rvld
add wave -noupdate /tb_convolver/convolver_inst/out_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {295000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {226940 ps} {413610 ps}
