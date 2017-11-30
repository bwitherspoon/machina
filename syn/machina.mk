SYN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SYN_SRC_DIR := $(SYN_DIR)src/
SYN_INC_DIR := $(SYN_DIR)inc/

vpath %.v $(SYN_SRC_DIR)
vpath %.vh $(SYN_INC_DIR)

SYN_BASE := $(notdir $(basename $(wildcard $(SYN_SRC_DIR)*.v)))
SYN_CHECK := $(addprefix check-syn-,$(SYN_BASE))
SYN_SYNTH := $(SYN_DIR)associate.blif $(SYN_DIR)heaviside.blif $(SYN_DIR)memory.blif

IVERILOG_FLAGS += -y$(SYN_SRC_DIR) -I$(SYN_INC_DIR)
VERILATOR_FLAGS += -y $(SYN_SRC_DIR) -I$(SYN_INC_DIR)

all: all-syn

check: check-syn

clean: clean-syn

all-syn: synth

check-syn: $(SYN_CHECK)

$(SYN_CHECK): check-syn-%: %.v
	@$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_VFLAGS) -tnull $<
	@$(VERILATOR) $(VERILATOR_FLAGS) --lint-only $<
	@$(YOSYS) -q $<

synth: $(SYN_SYNTH)

$(SYN_DIR)%.blif: %.v
	@$(YOSYS) -q -l $(@:.blif=.log) -o $@ -S $<

clean-syn:
	-$(RM) $(SYN_DIR)*.{blif,log}

.PHONY: all check all-syn check-syn $(SYN_CHECK) synth
