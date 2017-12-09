prj := machina
prj_dir := $(dir $(firstword $(MAKEFILE_LIST)))

IVERILOG ?= iverilog
IVERILOG_FLAGS := -Wall
ifndef DEBUG
IVERILOG_FLAGS += -DNDEBUG
endif
ifdef FINISH
IVERILOG_FLAGS += -DFINISH
endif

VVP ?= vvp

VERILATOR ?= verilator
VERILATOR_FLAGS := -Wall -Wno-fatal

YOSYS ?= yosys
YOSYS_FLAGS := -q

define check-program
	@command -v $(1) > /dev/null 2>&1 || { echo "ERROR: $(1) command not found in PATH" >&2; exit 1; }
endef

.DELETE_ON_ERROR:

all:

help:
	@echo ""
	@echo " make [TARGET]"
	@echo ""
	@echo " TARGET ::= all | check | test | clean"
	@echo ""

check: check-makefile

check-makefile:
	@$(MAKE) --dry-run --warn-undefined-variables --makefile=$(firstword $(MAKEFILE_LIST)) all > /dev/null

include dev/machina.mk
include dat/machina.mk
include inc/machina.mk
include syn/machina.mk
include sim/machina.mk
include sys/*/machina.mk

.PHONY: all help check test clean check-makefile
