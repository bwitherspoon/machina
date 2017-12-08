sim_dir := $(dir $(lastword $(MAKEFILE_LIST)))
sim_src_dir := $(sim_dir)src/
sim_dep_dir := $(sim_dir)dep/
sim_vvp_dir := $(sim_dir)vvp/
sim_vcd_dir := $(sim_dir)vcd/
sim_src := $(notdir $(wildcard $(sim_src_dir)*_test.sv))
sim_tst_tgt := $(addprefix test-,$(sim_src:_test.sv=))
sim_chk_tgt := $(addprefix check-,$(sim_src:_test.sv=))
sim_vcd_tgt := $(addprefix $(sim_vcd_dir),$(sim_src:.sv=.vcd))

IVERILOG_FLAGS += -Y.sv -y$(sim_src_dir)

vpath %.sv $(sim_src_dir)

all: all-sim

test: test-sim

check: check-sim

clean: clean-sim

dump: dump-sim

all-sim: dump-sim

test-sim: $(sim_tst_tgt)

check-sim: $(sim_chk_tgt)

clean-sim:
	-$(RM) -r $(sim_dep_dir) $(sim_vvp_dir) $(sim_vcd_dir)

$(sim_dep_dir) $(sim_vvp_dir) $(sim_vcd_dir):
	@mkdir -p $@

test-sigmoid:: $(dat_sig_act) $(dat_sig_der)

$(sim_tst_tgt):: test-%: $(sim_vvp_dir)%_test.vvp
	@$(VVP) -N -l- $< -none > /dev/null 2>$(<:.vvp=.log) && \
	echo "PASS: $*" || { echo "FAIL: $*"; cat $(<:.vvp=.log); exit 1; }

$(sim_chk_tgt):: check-%: %_test.sv
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull $<

dump-sim: $(sim_vcd_tgt)

$(sim_vcd_dir)%.vcd: $(sim_vvp_dir)%.vvp | $(sim_vcd_dir)
	@$(VVP) -n -l- $< -vcd +dumpfile=$@ > /dev/null 2>$(@:.vcd=.log)

$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Ptop.act=\"$(dat_sig_act)\"
$(sim_vvp_dir)sigmoid_test.vvp: IVERILOG_FLAGS += -Ptop.der=\"$(dat_sig_der)\"

$(sim_vvp_dir)%.vvp:: %.sv | $(sim_vvp_dir)
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tvvp -o $@ $<

$(sim_dep_dir)%.mk:: %.sv | $(sim_dep_dir)
	@trap 'rm -f $@.$$$$' EXIT; \
	trap '[ -e "$(@:.mk=.log)" ] && cat "$(@:.mk=.log)" 1>&2; rm -f $@' ERR; \
	set -e; \
	$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull -Mall=$@.$$$$ $< > $(@:.mk=.log) 2>&1; \
	basename -a `uniq $@.$$$$` | sed '1i$(sim_vvp_dir)$*.vvp $@:' | sed ':x;N;s/\n/ /;bx' > $@
	@$(RM) $(@:.mk=.log)

ifneq ($(MAKECMDGOALS),clean)
include $(sim_src:%.sv=$(sim_dep_dir)%.mk)
endif

.PHONY: all test check clean dump all-sim test-sim check-sim clean-sim dump-sim
.PHONY: $(sim_tst_tgt) $(sim_chk_tgt)
