SYN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SYN_SRC_DIR := $(SYN_DIR)src/
SYN_INC_DIR := $(SYN_DIR)inc/
SYN_LOG_DIR := $(SYN_DIR)log/
SYN_BLIF_DIR := $(SYN_DIR)blif/

SYN_NAME := $(notdir $(basename $(wildcard $(SYN_SRC_DIR)*.v)))
SYN_CHECK := $(addprefix check-,$(SYN_NAME))
SYN_SYNTH := $(addprefix $(SYN_BLIF_DIR),$(SYN_NAME:=.blif))

IVERILOG_FLAGS += -y$(SYN_SRC_DIR) -I$(SYN_INC_DIR)
VERILATOR_FLAGS += -y $(SYN_SRC_DIR) -I$(SYN_INC_DIR)

vpath %.v $(SYN_SRC_DIR)
vpath %.vh $(SYN_INC_DIR)

all: all-syn

check: check-syn

clean: clean-syn

all-syn: $(SYN_SYNTH)

check-syn: $(SYN_CHECK)

$(SYN_CHECK):: check-%: %.v
	@$(IVERILOG) -g2005 $(IVERILOG_FLAGS) -tnull $<
	@$(VERILATOR) $(VERILATOR_FLAGS) --lint-only $<
	@$(YOSYS) -q $<

$(SYN_BLIF_DIR)sigmoid.blif:: memory.v $(GEN_SIG_ACT) $(GEN_SIG_ACT)

$(SYN_BLIF_DIR)%.blif:: %.v | $(SYN_BLIF_DIR) $(SYN_LOG_DIR)
	@if [ -e '$(SYN_DIR)$*.ys' ]; then \
		echo '$(YOSYS) -q -l $(SYN_LOG_DIR)$*-blif.log -o $@ -s $(SYN_DIR)$*.ys'; \
		$(YOSYS) -q -l $(SYN_LOG_DIR)$*-blif.log -o $@ -s $(SYN_DIR)$*.ys; \
	else \
		echo '$(YOSYS) -q -l $(SYN_LOG_DIR)$*-blif.log -o $@ -S $(filter %.v,$^)'; \
		$(YOSYS) -q -l $(SYN_LOG_DIR)$*-blif.log -o $@ -S $(filter %.v,$^); \
	fi

$(SYN_BLIF_DIR) $(SYN_LOG_DIR):
	@mkdir -p $@

clean-syn:
	-$(RM) -r $(SYN_BLIF_DIR) $(SYN_LOG_DIR)

.PHONY: all check clean all-syn check-syn clean-syn $(SYN_CHECK)
