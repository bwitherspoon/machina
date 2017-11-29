SIM_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SIM_SRC_DIR := $(SIM_DIR)src/
SIM_INC_DIR := $(SIM_DIR)inc/
SIM_DEP_DIR := $(SIM_DIR)dep/
SIM_VVP_DIR := $(SIM_DIR)vvp/
SIM_VCD_DIR := $(SIM_DIR)vcd/
SIM_LXT_DIR := $(SIM_DIR)lxt/
SIM_FST_DIR := $(SIM_DIR)fst/

vpath %.sv $(SIM_SRC_DIR)
vpath %.svh $(SIM_INC_DIR)

IVERILOG_FLAGS += -y$(SIM_SRC_DIR) -I$(SIM_INC_DIR)

SIM_BASE := $(notdir $(wildcard $(SIM_SRC_DIR)*_test.sv))
SIM_STEM := $(patsubst %_test.sv,%,$(SIM_BASE))
SIM_TEST := $(addprefix sim-test-,$(SIM_STEM))
SIM_LINT := $(addprefix sim-lint-,$(SIM_STEM))
SIM_DUMP_VCD := $(addprefix $(SIM_VCD_DIR),$(addsuffix _tb.vcd,$(SIM_STEM)))
SIM_DUMP_LXT := $(addprefix $(SIM_LXT_DIR),$(addsuffix _tb.lxt,$(SIM_STEM)))
SIM_DUMP_FST := $(addprefix $(SIM_FST_DIR),$(addsuffix _tb.fst,$(SIM_STEM)))

all:

test: sim-test

lint: sim-lint

clean: sim-clean

sim-all: sim-lint

sim-test: $(SIM_TEST)

sim-lint: $(SIM_LINT)

$(SIM_TEST): sim-test-%: $(SIM_VVP_DIR)%_test.vvp
	@$(VVP) -N $< -none

$(SIM_LINT): sim-lint-%: %_test.sv
	@$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_SVFLAGS) -tnull $<

sim-clean:
	-$(RM) -r $(SIM_DEP_DIR) $(SIM_VVP_DIR) $(SIM_VCD_DIR) $(SIM_LXT_DIR) $(SIM_FST_DIR)

$(SIM_DEP_DIR) $(SIM_VVP_DIR) $(SIM_VCD_DIR) $(SIM_LXT_DIR) $(SIM_FST_DIR):
	@mkdir -p $@

sim-dump: sim-dump-vcd

sim-dump-vcd: $(SIM_DUMP_VCD)

sim-dump-lxt: $(SIM_DUMP_LXT)

sim-dump-fst: $(SIM_DUMP_FST)

$(SIM_VCD_DIR)%.vcd: $(SIM_VVP_DIR)%.vvp | $(SIM_VCD_DIR)
	@$(VVP) -N $< -vcd +dumpfile=$@

$(SIM_LXT_DIR)%.lxt: $(SIM_VVP_DIR)%.vvp | $(SIM_LXT_DIR)
	@$(VVP) -N $< -lxt2 +dumpfile=$@

$(SIM_FST_DIR)%.fst: $(SIM_VVP_DIR)%.vvp | $(SIM_FST_DIR)
	@$(VVP) -N $< -fst +dumpfile=$@

$(SIM_VVP_DIR)sigmoid_test.vvp: $(GEN_DAT_DIR)sigmoid_activ.dat $(GEN_DAT_DIR)sigmoid_deriv.dat
$(SIM_VVP_DIR)sigmoid_test.vvp: IVERILOG_FLAGS += -Psigmoid_test.activ=\"$(GEN_DAT_DIR)sigmoid_activ.dat\"
$(SIM_VVP_DIR)sigmoid_test.vvp: IVERILOG_FLAGS += -Psigmoid_test.deriv=\"$(GEN_DAT_DIR)sigmoid_deriv.dat\"

$(SIM_VVP_DIR)%.vvp: %.sv | $(SIM_VVP_DIR)
	@$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_SVFLAGS) -tvvp -o $@ $<

ifneq ($(MAKECMDGOALS),clean)
include $(SIM_BASE:%.sv=$(SIM_DEP_DIR)%.mk)
endif

$(SIM_DEP_DIR)%.mk: %.sv | $(SIM_DEP_DIR)
	@trap 'rm -f $@.$$$$' EXIT; trap 'rm -f $@' ERR; set -e; \
	$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_SVFLAGS) -tnull -Mall=$@.$$$$ $< > /dev/null 2>&1; \
	basename -a `uniq $@.$$$$` | sed '1i$(SIM_VVP_DIR)$*.vvp $@:' | sed ':x;N;s/\n/ /;bx' > $@

.PHONY: sim test lint clean sim-test sim-lint sim-clean
.PHONY: sim-dump sim-dump-vcd sim-dump-lxt sim-dump-fst
.PHONY: $(SIM_TEST) $(SIM_LINT)
