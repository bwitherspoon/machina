sim_dir := $(dir $(lastword $(MAKEFILE_LIST)))
sim_src_dir := $(sim_dir)src/
sim_dep_dir := $(sim_dir)dep/
sim_vvp_dir := $(sim_dir)vvp/
sim_vcd_dir := $(sim_dir)vcd/
sim_src := $(notdir $(wildcard $(sim_src_dir)*_test.sv))
sim_tst_tgt := $(addprefix test-,$(sim_src:_test.sv=))
sim_chk_tgt := $(addprefix check-,$(sim_src:_test.sv=))
sim_dmp_tgt := $(addprefix dump-,$(sim_src:_test.sv=))
sim_vvp_tgt := $(addprefix $(sim_vvp_dir),$(sim_src:.sv=.vvp))

IVERILOG_FLAGS += -Y.sv -y$(sim_src_dir)

SEED ?= $(shell echo $$RANDOM)

vpath %.sv $(sim_src_dir)

all: all-sim

test: test-sim

check: check-sim

dump: dump-sim

clean: clean-sim

all-sim: $(sim_vvp_tgt)

test-sim: $(sim_tst_tgt)

check-sim: $(sim_chk_tgt)

dump-sim: $(sim_dmp_tgt)

clean-sim:
	-$(RM) -r $(sim_dep_dir) $(sim_vvp_dir) $(sim_vcd_dir)

$(sim_dep_dir) $(sim_vvp_dir) $(sim_vcd_dir):
	@mkdir -p $@

test-sigmoid:: $(dat_sig_act) $(dat_sig_der)

$(sim_tst_tgt):: test-%: $(sim_vvp_dir)%_test.vvp
	@$(VVP) -N -l- $< -none +seed=$(SEED) > /dev/null 2>$(<:.vvp=.log) && \
	echo 'PASS: $*' || \
	{ echo 'FAIL: $*'; cat $(<:.vvp=.log) | sed 's,^,$(<:.vvp=.log): ,' 1>&2; exit 1; }

$(sim_chk_tgt):: check-%: %_test.sv
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull $<

$(sim_dmp_tgt):: dump-%: $(sim_vcd_dir)%_test.vcd

$(sim_vcd_dir)%.vcd: $(sim_vvp_dir)%.vvp | $(sim_vcd_dir)
	$(VVP) -n -l- $< -vcd +dumpfile=$@ +seed=$(SEED) > /dev/null 2>$(@:.vcd=.log)

$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Ptop.act=\"$(dat_sig_act)\"
$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Ptop.der=\"$(dat_sig_der)\"

$(sim_vvp_dir)%.vvp:: %.sv | $(sim_vvp_dir)
	$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tvvp -o $@ $<

$(sim_dep_dir)%.mk:: %.sv | $(sim_dep_dir)
	$(call generate-depends,$(sim_vvp_dir)$*.vvp)

ifneq ($(MAKECMDGOALS),clean)
include $(sim_src:%.sv=$(sim_dep_dir)%.mk)
endif

.PHONY: all test check dump clean
.PHONY: all-sim test-sim check-sim dump-sim clean-sim
.PHONY: $(sim_tst_tgt) $(sim_chk_tgt) $(sim_dmp_tgt)
