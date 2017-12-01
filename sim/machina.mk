SIM_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SIM_SRC_DIR := $(SIM_DIR)src/
SIM_INC_DIR := $(SIM_DIR)inc/
SIM_DEP_DIR := $(SIM_DIR)dep/
SIM_VVP_DIR := $(SIM_DIR)vvp/
SIM_VCD_DIR := $(SIM_DIR)vcd/
SIM_LXT_DIR := $(SIM_DIR)lxt/
SIM_FST_DIR := $(SIM_DIR)fst/
SIM_LOG_DIR := $(SIM_DIR)log/
SIM_SUB_DIR := $(SIM_DEP_DIR) \
							 $(SIM_VVP_DIR) \
							 $(SIM_VCD_DIR) \
							 $(SIM_LXT_DIR) \
							 $(SIM_FST_DIR) \
							 $(SIM_LOG_DIR)

SIM_FILE := $(notdir $(wildcard $(SIM_SRC_DIR)*_test.sv))
SIM_NAME := $(patsubst %_test.sv,%,$(SIM_FILE))
SIM_TEST := $(addprefix test-,$(SIM_NAME))
SIM_CHECK := $(addprefix check-,$(SIM_NAME))
SIM_VCD := $(addprefix $(SIM_VCD_DIR),$(addsuffix _test.vcd,$(SIM_NAME)))
SIM_LXT := $(addprefix $(SIM_LXT_DIR),$(addsuffix _test.lxt,$(SIM_NAME)))
SIM_FST := $(addprefix $(SIM_FST_DIR),$(addsuffix _test.fst,$(SIM_NAME)))

IVERILOG_FLAGS += -Y.sv -y$(SIM_SRC_DIR) -I$(SIM_INC_DIR)

vpath %.sv $(SIM_SRC_DIR)
vpath %.svh $(SIM_INC_DIR)

all: all-sim

test: test-sim

check: check-sim

clean: clean-sim

all-sim: sim-vcd

test-sim: $(SIM_TEST)

check-sim: $(SIM_CHECK)

clean-sim:
	-$(RM) -r $(SIM_SUB_DIR)

$(SIM_TEST):: test-%: $(SIM_VVP_DIR)%_test.vvp | $(SIM_LOG_DIR)
	@$(VVP) $(VVP_FLAGS) -l- $< -none > /dev/null 2>$(SIM_LOG_DIR)/$*.log && echo "PASS: $*" || { echo "FAIL: $*"; exit 1; }

$(SIM_CHECK):: check-%: %_test.sv
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull $<

$(SIM_SUB_DIR):
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

$(SIM_VVP_DIR)%.vvp:: %.sv | $(SIM_VVP_DIR)
	@$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tvvp -o $@ $<

$(SIM_DEP_DIR)%.mk:: %.sv | $(SIM_DEP_DIR)
	@trap 'rm -f $@.$$$$' EXIT; trap 'rm -f $@' ERR; set -e; \
	$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull -Mall=$@.$$$$ $< > $(SIM_DEP_DIR)/$*.log 2>&1; \
	basename -a `uniq $@.$$$$` | sed '1i$(SIM_VVP_DIR)$*.vvp $@:' | sed ':x;N;s/\n/ /;bx' > $@
	@$(RM) $(SIM_DEP_DIR)/$*.log

ifneq ($(MAKECMDGOALS),clean)
include $(SIM_FILE:%.sv=$(SIM_DEP_DIR)%.mk)
endif

.PHONY: all test check clean all-sim test-sim check-sim clean-sim
.PHONY: $(SIM_TEST) $(SIM_CHECK) sim-vcd sim-lxt sim-fst
