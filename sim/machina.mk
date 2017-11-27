SIMDIR := $(dir $(lastword $(MAKEFILE_LIST)))
HDLDIR := $(SIMDIR)hdl/

vpath %.sv $(HDLDIR)
vpath %.svh $(HDLDIR)

IVERILOG_VFLAGS += -y$(HDLDIR) -I$(HDLDIR)
IVERILOG_SVFLAGS += -y$(HDLDIR) -I$(HDLDIR)
ifdef DEBUG
IVERILOG_VFLAGS += -DDEBUG
IVERILOG_SVFLAGS += -DDEBUG
endif

SIM_NAME := $(patsubst %_tb.sv,%,$(notdir $(wildcard $(HDLDIR)*_tb.sv)))
SIM_TEST := $(addprefix sim-test-,$(SIM_NAME))
SIM_LINT := $(addprefix sim-lint-,$(SIM_NAME))

test: sim-test

lint: sim-lint

sim-test: $(SIM_TEST)

sim-lint: $(SIM_LINT)

$(SIM_LINT): sim-lint-%: %_tb.sv
	$(IVERILOG) $(IVERILOG_SVFLAGS) -tnull $<
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

$(SIM_TEST): sim-test-%: %_tb.vvp
	$(VVP) -N $< -none
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

%.vcd: %.vcd.vvp
	$(VVP) -N $< -vcd

%.lxt: %.lxt.vvp
	$(VVP) -N $< -lxt2

%.fst: %.fst.vvp
	$(VVP) -N $< -fst

%.vcd.vvp: IVERILOG_SVFLAGS += -DDUMPFILE=$*.vcd
%.lxt.vvp: IVERILOG_SVFLAGS += -DDUMPFILE=$*.lxt
%.fst.vvp: IVERILOG_SVFLAGS += -DDUMPFILE=$*.fst
%.vvp %.vcd.vvp %.lxt.vvp %.fst.vvp: %.sv
	$(IVERILOG) $(IVERILOG_SVFLAGS) -tvvp -o $@ $<

.PHONY: test lint sim-test sim-lint $(SIM_TEST) $(SIM_LINT)
