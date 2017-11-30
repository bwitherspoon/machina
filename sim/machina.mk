SIM_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SIM_SRC_DIR := $(SIM_DIR)src/
SIM_INC_DIR := $(SIM_DIR)inc/
SIM_DEP_DIR := $(SIM_DIR)dep/
SIM_VVP_DIR := $(SIM_DIR)vvp/
SIM_VCD_DIR := $(SIM_DIR)vcd/
SIM_LXT_DIR := $(SIM_DIR)lxt/
SIM_FST_DIR := $(SIM_DIR)fst/
SIM_LOG_DIR := $(SIM_DIR)log/

vpath %.sv $(SIM_SRC_DIR)
vpath %.svh $(SIM_INC_DIR)

SIM_BASE := $(notdir $(wildcard $(SIM_SRC_DIR)*_test.sv))
SIM_STEM := $(patsubst %_test.sv,%,$(SIM_BASE))
SIM_TEST := $(addprefix test-sim-,$(SIM_STEM))
SIM_CHECK := $(addprefix check-sim-,$(SIM_STEM))
SIM_VCD := $(addprefix $(SIM_VCD_DIR),$(addsuffix _test.vcd,$(SIM_STEM)))
SIM_LXT := $(addprefix $(SIM_LXT_DIR),$(addsuffix _test.lxt,$(SIM_STEM)))
SIM_FST := $(addprefix $(SIM_FST_DIR),$(addsuffix _test.fst,$(SIM_STEM)))

IVERILOG_FLAGS += -y$(SIM_SRC_DIR) -I$(SIM_INC_DIR)

all: all-sim

test: test-sim

check: check-sim

clean: clean-sim

all-sim: sim-vcd

test-sim: $(SIM_TEST)

check-sim: $(SIM_CHECK)

clean-sim:
	-$(RM) -r $(SIM_DEP_DIR) $(SIM_VVP_DIR) $(SIM_VCD_DIR) $(SIM_LXT_DIR) $(SIM_FST_DIR) $(SIM_LOG_DIR)

$(SIM_TEST): test-sim-%: $(SIM_VVP_DIR)%_test.vvp | $(SIM_LOG_DIR)
	@$(VVP) $(VVP_FLAGS) -l- $< -none > /dev/null 2>$(SIM_LOG_DIR)/$*.log || { echo "FAIL: $*"; exit 1; }
	@echo "PASS: $*"

$(SIM_CHECK): check-sim-%: %_test.sv
	@$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_SVFLAGS) -tnull $<

$(SIM_DEP_DIR) $(SIM_VVP_DIR) $(SIM_VCD_DIR) $(SIM_LXT_DIR) $(SIM_FST_DIR) $(SIM_LOG_DIR):
	@mkdir -p $@

sim-vcd: $(SIM_VCD)

sim-lxt: $(SIM_LXT)

sim-fst: $(SIM_FST)

$(SIM_VCD_DIR)%.vcd: $(SIM_VVP_DIR)%.vvp | $(SIM_VCD_DIR) $(SIM_LOG_DIR)
	@$(VVP) $(VVP_FLAGS) -l- $< -vcd +dumpfile=$@ > /dev/null 2>$(SIM_LOG_DIR)/$*-vcd.log

$(SIM_LXT_DIR)%.lxt: $(SIM_VVP_DIR)%.vvp | $(SIM_LXT_DIR) $(SIM_LOG_DIR)
	@$(VVP) $(VVP_FLAGS) -l- $< -lxt2 +dumpfile=$@ > /dev/null 2>$(SIM_LOG_DIR)/$*-lxt.log

$(SIM_FST_DIR)%.fst: $(SIM_VVP_DIR)%.vvp | $(SIM_FST_DIR) $(SIM_LOG_DIR)
	@$(VVP) $(VVP_FLAGS) -l- $< -fst +dumpfile=$@ > /dev/null 2>$(SIM_LOG_DIR)/$*-fst.log

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

.PHONY: all test check clean all-sim test-sim check-sim clean-sim
.PHONY: dump dump-vcd dump-lxt dump-fst
.PHONY: $(SIM_TEST) $(SIM_CHECK)
