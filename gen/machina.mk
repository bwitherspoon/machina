gen_dir := $(dir $(lastword $(MAKEFILE_LIST)))
gen_src_dir := $(gen_dir)src/
gen_inc_dir := $(gen_dir)src/
gen_dat_dir := $(gen_dir)dat/
gen_sig_act := $(gen_dat_dir)sigmoid_activ.dat
gen_sig_der := $(gen_dat_dir)sigmoid_deriv.dat
gen_dat := $(gen_sig_act) $(gen_sig_der)
gen_mem := $(gen_dir)mem

vpath %.cc $(gen_src_dir)
vpath %.h $(gen_inc_dir)

all:

clean: clean-gen

all-gen: gen-mem gen-dat

clean-gen:
	-$(RM) -r $(gen_dir)mem $(gen_dat_dir)

$(gen_dat_dir):
	@mkdir -p $@

gen-mem: $(gen_mem)

gen-dat: $(gen_dat)

$(gen_mem): LDFLAGS += -lboost_program_options
$(gen_mem): driver.cc memory.h sigmoid.h -lboost_program_options
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $<

$(gen_sig_act): FUNCT = sigmoid
$(gen_sig_act): WIDTH = 8
$(gen_sig_act): DEPTH = 4096
$(gen_sig_act): SCALE = 255

$(gen_sig_der): FUNCT = sigmoid-prime
$(gen_sig_der): WIDTH = 7
$(gen_sig_der): DEPTH = 4096
$(gen_sig_der): SCALE = 255

$(gen_dat_dir)%.dat: FUNCT ?= random
$(gen_dat_dir)%.dat: WIDTH ?= 8
$(gen_dat_dir)%.dat: DEPTH ?= 4096
$(gen_dat_dir)%.dat: SCALE ?= 256
$(gen_dat_dir)%.dat: $(gen_mem) | $(gen_dat_dir)
	$< -f $(FUNCT) -w $(WIDTH) -d $(DEPTH) -s $(SCALE) > $@

.PHONY: all clean all-gen clean-gen gen-mem gen-dat
