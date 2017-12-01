sim_dir := $(dir $(lastword $(MAKEFILE_LIST)))
sim_src_dir := $(sim_dir)src/
sim_inc_dir := $(sim_dir)inc/
sim_dep_dir := $(sim_dir)dep/
sim_vvp_dir := $(sim_dir)vvp/
sim_vcd_dir := $(sim_dir)vcd/
sim_lxt_dir := $(sim_dir)lxt/
sim_fst_dir := $(sim_dir)fst/
sim_log_dir := $(sim_dir)log/
sim_sub_dir := $(sim_dep_dir) \
							 $(sim_vvp_dir) \
							 $(sim_vcd_dir) \
							 $(sim_lxt_dir) \
							 $(sim_fst_dir) \
							 $(sim_log_dir)

sim_file := $(notdir $(wildcard $(sim_src_dir)*_test.sv))
sim_name := $(patsubst %_test.sv,%,$(sim_file))
sim_test := $(addprefix test-,$(sim_name))
sim_check := $(addprefix check-,$(sim_name))
sim_vcd := $(addprefix $(sim_vcd_dir),$(addsuffix _test.vcd,$(sim_name)))
sim_lxt := $(addprefix $(sim_lxt_dir),$(addsuffix _test.lxt,$(sim_name)))
sim_fst := $(addprefix $(sim_fst_dir),$(addsuffix _test.fst,$(sim_name)))

IVERILOG_FLAGS += -Y.sv -y$(sim_src_dir) -I$(sim_inc_dir)

vpath %.sv $(sim_src_dir)
vpath %.svh $(sim_inc_dir)

all: all-sim

test: test-sim

check: check-sim

clean: clean-sim

all-sim: sim-vcd

test-sim: $(sim_test)

check-sim: $(sim_check)

clean-sim:
	-$(RM) -r $(sim_sub_dir)

$(sim_test):: test-%: $(sim_vvp_dir)%_test.vvp | $(sim_log_dir)
	@$(VVP) $(VVP_FLAGS) -l- $< -none > /dev/null 2>$(sim_log_dir)/$*.log && echo "PASS: $*" || { echo "FAIL: $*"; exit 1; }

$(sim_check):: check-%: %_test.sv
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull $<

$(sim_sub_dir):
	@mkdir -p $@

sim-vcd: $(sim_vcd)

sim-lxt: $(sim_lxt)

sim-fst: $(sim_fst)

$(sim_vcd_dir)%.vcd: $(sim_vvp_dir)%.vvp | $(sim_vcd_dir) $(sim_log_dir)
	@$(VVP) $(VVP_FLAGS) -l- $< -vcd +dumpfile=$@ > /dev/null 2>$(sim_log_dir)/$*-vcd.log

$(sim_lxt_dir)%.lxt: $(sim_vvp_dir)%.vvp | $(sim_lxt_dir) $(sim_log_dir)
	@$(VVP) $(VVP_FLAGS) -l- $< -lxt2 +dumpfile=$@ > /dev/null 2>$(sim_log_dir)/$*-lxt.log

$(sim_fst_dir)%.fst: $(sim_vvp_dir)%.vvp | $(sim_fst_dir) $(sim_log_dir)
	@$(VVP) $(VVP_FLAGS) -l- $< -fst +dumpfile=$@ > /dev/null 2>$(sim_log_dir)/$*-fst.log

$(sim_vvp_dir)sigmoid_test.vvp: $(gen_dat_dir)sigmoid_activ.dat $(gen_dat_dir)sigmoid_deriv.dat
$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Psigmoid_test.activ=\"$(gen_dat_dir)sigmoid_activ.dat\"
$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Psigmoid_test.deriv=\"$(gen_dat_dir)sigmoid_deriv.dat\"

$(sim_vvp_dir)%.vvp:: %.sv | $(sim_vvp_dir)
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tvvp -o $@ $<

$(sim_dep_dir)%.mk:: %.sv | $(sim_dep_dir)
	@trap 'rm -f $@.$$$$' EXIT; trap 'rm -f $@' ERR; set -e; \
	$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull -Mall=$@.$$$$ $< > $(sim_dep_dir)/$*.log 2>&1; \
	basename -a `uniq $@.$$$$` | sed '1i$(sim_vvp_dir)$*.vvp $@:' | sed ':x;N;s/\n/ /;bx' > $@
	@$(RM) $(sim_dep_dir)/$*.log

ifneq ($(MAKECMDGOALS),clean)
include $(sim_file:%.sv=$(sim_dep_dir)%.mk)
endif

.PHONY: all test check clean all-sim test-sim check-sim clean-sim
.PHONY: $(sim_test) $(sim_check) sim-vcd sim-lxt sim-fst
