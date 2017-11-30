SYN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SYN_SRC_DIR := $(SYN_DIR)src/
SYN_INC_DIR := $(SYN_DIR)inc/
SYN_LOG_DIR := $(SYN_DIR)log/
SYN_BLIF_DIR := $(SYN_DIR)blif/

vpath %.v $(SYN_SRC_DIR)
vpath %.vh $(SYN_INC_DIR)

SYN_BASE := $(notdir $(basename $(wildcard $(SYN_SRC_DIR)*.v)))
SYN_CHECK := $(addprefix check-syn-,$(SYN_BASE))
SYN_SYNTH := $(addprefix $(SYN_BLIF_DIR),associate.blif heaviside.blif memory.blif)

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

$(SYN_BLIF_DIR)%.blif: %.v | $(SYN_BLIF_DIR) $(SYN_LOG_DIR)
	$(YOSYS) -q -l $(SYN_LOG_DIR)$*-blif.log -o $@ -S $<

$(SYN_BLIF_DIR) $(SYN_LOG_DIR):
	@mkdir -p $@

clean-syn:
	-$(RM) -r $(SYN_BLIF_DIR) $(SYN_LOG_DIR)

.PHONY: all check all-syn check-syn $(SYN_CHECK) synth
