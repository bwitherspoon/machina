dat_dir := $(dir $(lastword $(MAKEFILE_LIST)))
dat_sig_act := $(dat_dir)sigmoid_act.dat
dat_sig_der := $(dat_dir)sigmoid_der.dat

all: all-dat

clean: clean-dat

all-dat: $(dat_sig_act) $(dat_sig_der)

clean-dat:
	-$(RM) -r $(dat_sig_act) $(dat_sig_der)

$(dat_sig_act): FUNCT = sigmoid
$(dat_sig_act): WIDTH = 8
$(dat_sig_act): DEPTH = 4096
$(dat_sig_act): SCALE = 255

$(dat_sig_der): FUNCT = sigmoid-prime
$(dat_sig_der): WIDTH = 7
$(dat_sig_der): DEPTH = 4096
$(dat_sig_der): SCALE = 255

$(dat_dir)%.dat: FUNCT ?= random
$(dat_dir)%.dat: WIDTH ?= 8
$(dat_dir)%.dat: DEPTH ?= 4096
$(dat_dir)%.dat: SCALE ?= 256
$(dat_dir)%.dat: $(dev_mem)
	$< -f $(FUNCT) -w $(WIDTH) -d $(DEPTH) -s $(SCALE) > $@

.PHONY: all clean all-dat clean-dat
