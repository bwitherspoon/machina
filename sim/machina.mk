sim_dir := $(dir $(lastword $(MAKEFILE_LIST)))
sim_src_dir := $(sim_dir)src/
sim_vvp_dir := $(sim_dir)vvp/
sim_vcd_dir := $(sim_dir)vcd/

sim_src := $(notdir $(wildcard $(sim_src_dir)*_test.sv))
sim_dep := $(addprefix $(dep_dir),$(sim_src:.sv=.mk))
sim_tst := $(addprefix test.,$(sim_src:_test.sv=))
sim_chk := $(addprefix check.,$(sim_src:_test.sv=))
sim_dmp := $(addprefix dump.,$(sim_src:_test.sv=))
sim_vvp := $(addprefix $(sim_vvp_dir),$(sim_src:.sv=.vvp))

IVERILOG_FLAGS += -y$(sim_src_dir:/=)

GTKWAVE ?= gtkwave

TIMESCALE ?= 1ns/1ps
SEED ?= $(shell echo $$RANDOM)

vpath %.sv $(sim_src_dir)

all: all.sim

test: test.sim

check: check.sim

dump: dump.sim

wave:
	@$(GTKWAVE) -n $(sim_vcd_dir) -S $(dev_dir)tcl/testbench.tcl >/dev/null 2>&1 &

clean: clean.sim

all.sim: $(sim_vvp)

test.sim: $(sim_tst)

check.sim: $(sim_chk)

dump.sim: $(sim_dmp)

clean.sim:
	-$(RM) -r $(sim_vvp_dir) $(sim_vcd_dir)

$(sim_vvp_dir) $(sim_vcd_dir):
	@mkdir -p $@

$(sim_tst): test.%: $(sim_vvp_dir)%_test.vvp
	@$(VVP) -N -l- $< -none +seed=$(SEED) > /dev/null 2>$(<:.vvp=.log) && \
	echo 'PASS: $*' || \
	{ echo 'FAIL: $*'; cat $(<:.vvp=.log) | sed 's,^,$(<:.vvp=.log): ,' 1>&2; exit 1; }

$(sim_chk):: check.%: %_test.sv
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull $<

$(sim_dmp): dump.%: $(sim_vcd_dir)%_test.vcd

$(sim_vcd_dir)%.vcd: $(sim_vvp_dir)%.vvp | $(sim_vcd_dir)
	$(VVP) -n -l- $< -vcd +dumpfile=$@ +seed=$(SEED) > /dev/null 2>$(@:.vcd=.log)

$(sim_vvp_dir)%.vvp:: %.sv | $(sim_vvp_dir)
	$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -ptimescale=$(TIMESCALE) -tvvp -o $@ $<

$(sim_dep): $(dep_dir)%.mk: %.sv | $(dep_dir)
	$(call depends,$(sim_vvp_dir)$*.vvp)

ifeq ($(findstring clean,$(MAKECMDGOALS)),)
-include $(sim_dep)
endif

.PHONY: all test check dump clean
.PHONY: all.sim test.sim check.sim dump.sim clean.sim
.PHONY: $(sim_tst) $(sim_chk) $(sim_dmp)
