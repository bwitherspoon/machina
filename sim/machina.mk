SIMDIR := $(dir $(lastword $(MAKEFILE_LIST)))
HDLDIR := $(SIMDIR)hdl/
VVPDIR := $(SIMDIR)vvp/
VCDDIR := $(SIMDIR)vcd/
LXTDIR := $(SIMDIR)lxt/
FSTDIR := $(SIMDIR)fst/

vpath %.sv $(HDLDIR)
vpath %.svh $(HDLDIR)

IVERILOG_FLAGS += -y$(HDLDIR) -I$(HDLDIR)

SIM_BASE := $(notdir $(wildcard $(HDLDIR)*_test.sv))
SIM_STEM := $(patsubst %_test.sv,%,$(SIM_BASE))
SIM_TEST := $(addprefix sim-test-,$(SIM_STEM))
SIM_LINT := $(addprefix sim-lint-,$(SIM_STEM))
SIM_DUMP_VCD := $(addprefix $(VCDDIR),$(addsuffix _tb.vcd,$(SIM_STEM)))
SIM_DUMP_LXT := $(addprefix $(LXTDIR),$(addsuffix _tb.lxt,$(SIM_STEM)))
SIM_DUMP_FST := $(addprefix $(FSTDIR),$(addsuffix _tb.fst,$(SIM_STEM)))

sim:

test: sim-test

lint: sim-lint

sim-test: $(SIM_TEST)

sim-lint: $(SIM_LINT)

sim-dump-vcd: $(SIM_DUMP_VCD)

sim-dump-lxt: $(SIM_DUMP_LXT)

sim-dump-fst: $(SIM_DUMP_FST)

$(SIM_LINT): sim-lint-%: %_test.sv
	@$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_SVFLAGS) -tnull $<
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

$(SIM_TEST): sim-test-%: $(VVPDIR)%_test.vvp
	@$(VVP) -N $< -none
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

$(VCDDIR)%.vcd: $(VVPDIR)%.vvp | $(VCDDIR)
	@$(VVP) -N $< -vcd +dumpfile=$@

$(LXTDIR)%.lxt: $(VVPDIR)%.vvp | $(LXTDIR)
	@$(VVP) -N $< -lxt2 +dumpfile=$@

$(FSTDIR)%.fst: $(VVPDIR)%.vvp | $(FSTDIR)
	@$(VVP) -N $< -fst +dumpfile=$@

$(VVPDIR)sigmoid_test.vvp: $(DATDIR)sigmoid_activ.dat $(DATDIR)sigmoid_deriv.dat

$(VVPDIR)%.vvp: %.sv | $(VVPDIR)
	@$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_SVFLAGS) -tvvp -o $@ $<

$(VVPDIR) $(VCDDIR) $(LXTDIR) $(FSTDIR):
	@mkdir -p $@

clean: sim-clean

sim-clean:
	-$(RM) -r $(VVPDIR) $(VCDDIR) $(LXTDIR) $(FSTDIR)

.PHONY: sim test lint clean
.PHONY: sim-test sim-lint sim-clean
.PHONY: sim-dump-vcd sim-dump-lxt sim-dump-fst
.PHONY: $(SIM_TEST) $(SIM_LINT)
