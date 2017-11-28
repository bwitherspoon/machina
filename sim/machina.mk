SIMDIR := $(dir $(lastword $(MAKEFILE_LIST)))
HDLDIR := $(SIMDIR)hdl/
VVPDIR := $(SIMDIR)vvp/
VCDDIR := $(SIMDIR)vcd/
LXTDIR := $(SIMDIR)lxt/
FSTDIR := $(SIMDIR)fst/

vpath %.sv $(HDLDIR)
vpath %.svh $(HDLDIR)

IVERILOG_FLAGS += -y$(HDLDIR) -I$(HDLDIR)
ifdef DEBUG
IVERILOG_FLAGS += -DDEBUG
endif

SIM_BASE := $(notdir $(wildcard $(HDLDIR)*_tb.sv))
SIM_STEM := $(patsubst %_tb.sv,%,$(SIM_BASE))
SIM_TEST := $(addprefix sim-test-,$(SIM_STEM))
SIM_LINT := $(addprefix sim-lint-,$(SIM_STEM))
SIM_DUMP_VCD := $(addprefix $(VCDDIR),$(addsuffix _tb.vcd,$(SIM_STEM)))
SIM_DUMP_LXT := $(addprefix $(LXTDIR),$(addsuffix _tb.lxt,$(SIM_STEM)))
SIM_DUMP_FST := $(addprefix $(FSTDIR),$(addsuffix _tb.fst,$(SIM_STEM)))

sim-all: sim-dump

test: sim-test

lint: sim-lint

dump: sim-dump

sim-test: $(SIM_TEST)

sim-lint: $(SIM_LINT)

sim-dump: sim-dump-vcd sim-dump-lxt sim-dump-fst

sim-dump-vcd: $(SIM_DUMP_VCD)

sim-dump-lxt: $(SIM_DUMP_LXT)

sim-dump-fst: $(SIM_DUMP_FST)

$(SIM_LINT): sim-lint-%: %_tb.sv
	$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_SVFLAGS) -tnull $<
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

$(SIM_TEST): sim-test-%: $(VVPDIR)%_tb.vvp
	$(VVP) -N $< -none
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

$(VCDDIR)%.vcd: $(VVPDIR)%.vvp | $(VCDDIR)
	$(VVP) -N $< -vcd +dumpfile=$@

$(LXTDIR)%.lxt: $(VVPDIR)%.vvp | $(LXTDIR)
	$(VVP) -N $< -lxt2 +dumpfile=$@

$(FSTDIR)%.fst: $(VVPDIR)%.vvp | $(FSTDIR)
	$(VVP) -N $< -fst +dumpfile=$@

$(VVPDIR)%.vvp: %.sv | $(VVPDIR)
	$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_SVFLAGS) -tvvp -o $@ $<

$(VVPDIR) $(VCDDIR) $(LXTDIR) $(FSTDIR):
	@mkdir -p $@

clean: sim-clean

sim-clean:
	-$(RM) -r $(VPPDIR) $(VCDDIR) $(LXTDIR) $(FSTDIR)

.PHONY: test lint dump clean
.PHONY: sim-all sim-test sim-lint sim-dump sim-clean
.PHONY: sim-dump-vcd sim-dump-lxt sim-dump-fst
.PHONY: $(SIM_TEST) $(SIM_LINT)
