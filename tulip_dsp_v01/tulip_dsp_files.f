-f ${IP_REPO}/polynomial_estimator_v01/polynomial_estimator_files.f
-f ${IP_REPO}/fixed_to_float_v1/fixed_to_float_files.f
-f ${IP_REPO}/float_to_fixed_v1/float_to_fixed_files.f

-makelib work
${IP_REPO}/tulip_dsp_v01/tulip_dsp.sv
-endlib
