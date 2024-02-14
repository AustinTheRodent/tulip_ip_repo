
-f ${IP_REPO}/kr260_tulip_top_0_0_1/axil_reg_file_v2/axil_reg_file_files.f
-f ${IP_REPO}/kr260_tulip_top_0_0_1/wm8960_i2c_v1_0/wm8960_i2c_files.f

-makelib work
${IP_REPO}/kr260_tulip_top_0_0_1/kr260_tulip_top_0_0_1.vhd
-endlib
