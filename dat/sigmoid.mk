$(dat_dir)sigmoid_funct.dat: FUNCT = sigmoid
$(dat_dir)sigmoid_funct.dat: WIDTH = 8
$(dat_dir)sigmoid_funct.dat: DEPTH = 4096
$(dat_dir)sigmoid_funct.dat: SCALE = 255

$(dat_dir)sigmoid_deriv.dat: FUNCT = sigmoid-prime
$(dat_dir)sigmoid_deriv.dat: WIDTH = 7
$(dat_dir)sigmoid_deriv.dat: DEPTH = 4096
$(dat_dir)sigmoid_deriv.dat: SCALE = 255

all-dat: $(dat_dir)sigmoid_funct.dat $(dat_dir)sigmoid_deriv.dat

test-sigmoid dump-sigmoid: $(dat_dir)sigmoid_funct.dat $(dat_dir)sigmoid_deriv.dat

$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Ptestbench.funct=\"$(dat_dir)sigmoid_funct.dat\"
$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Ptestbench.deriv=\"$(dat_dir)sigmoid_deriv.dat\"

$(syn_gen_dir)sigmoid.blif: $(dat_dir)sigmoid_funct.dat $(dat_dir)sigmoid_deriv.dat
