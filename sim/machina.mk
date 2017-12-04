sim_dir := $(dir $(lastword $(MAKEFILE_LIST)))
sim_src_dir := $(sim_dir)src/
sim_inc_dir := $(sim_dir)inc/
sim_dep_dir := $(sim_dir)dep/
sim_vvp_dir := $(sim_dir)vvp/
sim_vcd_dir := $(sim_dir)vcd/
sim_lxt_dir := $(sim_dir)lxt/
sim_fst_dir := $(sim_dir)fst/
sim_log_dir := $(sim_dir)log/
sim_out_dir := $(sim_dep_dir) \
							 $(sim_vvp_dir) \
							 $(sim_vcd_dir) \
							 $(sim_lxt_dir) \
							 $(sim_fst_dir) \
							 $(sim_log_dir)

sim_src := $(notdir $(wildcard $(sim_src_dir)*_test.sv))
sim_inc := $(notdir $(wildcard $(sim_inc_dir)*.svh))
sim_tgt := $(sim_src:_test.sv=)
sim_tst_tgt := $(addprefix test-,$(sim_tgt))
sim_chk_tgt := $(addprefix check-,$(sim_tgt))
sim_vcd_tgt := $(addprefix $(sim_vcd_dir),$(sim_tgt:=_test.vcd))
sim_lxt_tgt := $(addprefix $(sim_lxt_dir),$(sim_tgt:=_test.lxt))
sim_fst_tgt := $(addprefix $(sim_fst_dir),$(sim_tgt:=_test.fst))

IVERILOG_FLAGS += -Y.sv -y$(sim_src_dir) -I$(sim_inc_dir)

vpath %.sv $(sim_src_dir)
vpath %.svh $(sim_inc_dir)

all: all-sim

test: test-sim

check: check-sim

clean: clean-sim

all-sim: sim-vcd

test-sim: $(sim_tst_tgt)

check-sim: $(sim_chk_tgt)

clean-sim:
	-$(RM) -r $(sim_out_dir)

$(sim_out_dir):
	@mkdir -p $@

test-sigmoid:: $(gen_dat_dir)sigmoid_activ.dat $(gen_dat_dir)sigmoid_deriv.dat

$(sim_tst_tgt):: test-%: $(sim_vvp_dir)%_test.vvp | $(sim_log_dir)
	@$(VVP) $(VVP_FLAGS) -l- $< -none > /dev/null 2>$(sim_log_dir)/$*.log && \
	echo "PASS: $*" || { echo "FAIL: $*"; cat $(sim_log_dir)/$*.log; exit 1; }

$(sim_chk_tgt):: check-%: %_test.sv
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull $<

sim-vcd: $(sim_vcd_tgt)

sim-lxt: $(sim_lxt_tgt)

sim-fst: $(sim_fst_tgt)

$(sim_vcd_dir)%.vcd: $(sim_vvp_dir)%.vvp | $(sim_vcd_dir) $(sim_log_dir)
	@$(VVP) $(VVP_FLAGS) -l- $< -vcd +dumpfile=$@ > /dev/null 2>$(sim_log_dir)/$*-vcd.log

$(sim_lxt_dir)%.lxt: $(sim_vvp_dir)%.vvp | $(sim_lxt_dir) $(sim_log_dir)
	@$(VVP) $(VVP_FLAGS) -l- $< -lxt2 +dumpfile=$@ > /dev/null 2>$(sim_log_dir)/$*-lxt.log

$(sim_fst_dir)%.fst: $(sim_vvp_dir)%.vvp | $(sim_fst_dir) $(sim_log_dir)
	@$(VVP) $(VVP_FLAGS) -l- $< -fst +dumpfile=$@ > /dev/null 2>$(sim_log_dir)/$*-fst.log

$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Psigmoid_test.activ=\"$(gen_dat_dir)sigmoid_activ.dat\"
$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Psigmoid_test.deriv=\"$(gen_dat_dir)sigmoid_deriv.dat\"

$(sim_vvp_dir)%.vvp:: %.sv $(sim_inc) | $(sim_vvp_dir)
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tvvp -o $@ $<

$(sim_dep_dir)%.mk:: %.sv | $(sim_dep_dir)
	@trap 'rm -f $@.$$$$' EXIT; \
	trap '[ -e "$(sim_dep_dir)/$*.log" ] && cat "$(sim_dep_dir)/$*.log" 1>&2; rm -f $@' ERR; \
	set -e; \
	$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull -Mall=$@.$$$$ $< > $(sim_dep_dir)/$*.log 2>&1; \
	basename -a `uniq $@.$$$$` | sed '1i$(sim_vvp_dir)$*.vvp $@:' | sed ':x;N;s/\n/ /;bx' > $@
	@$(RM) $(sim_dep_dir)/$*.log

ifneq ($(MAKECMDGOALS),clean)
include $(sim_src:%.sv=$(sim_dep_dir)%.mk)
endif

.PHONY: all test check clean all-sim test-sim check-sim clean-sim
.PHONY: $(sim_tst_tgt) $(sim_chk_tgt) sim-vcd sim-lxt sim-fst
