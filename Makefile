prj_dir := $(dir $(firstword $(MAKEFILE_LIST)))

IVERILOG ?= iverilog
IVERILOG_FLAGS := -Wall
ifndef DEBUG
IVERILOG_FLAGS += -DNDEBUG
endif
ifdef NSTOP
IVERILOG_FLAGS += -DNSTOP
endif

VVP ?= vvp
VVP_FLAGS := -N

VERILATOR ?= verilator
VERILATOR_FLAGS := -Wall -Wno-fatal

YOSYS ?= yosys
YOSYS_FLAGS := -q

CXXFLAGS := -std=c++11 -Wall -Wextra
ifdef DEBUG
CXXFLAGS += -O0 -g
endif

define check-program
	@command -v $(1) > /dev/null 2>&1 || { echo "ERROR: $(1) command not found in PATH" >&2; exit 1; }
	@$(1) -V 2>&1 | head -n 1
endef

.DELETE_ON_ERROR:

all:

help:
	@echo ""
	@echo " make [TARGET]"
	@echo ""
	@echo " TARGET ::= all | check | test | clean"
	@echo ""

check: check-makefile check-programs

check-makefile:
	@$(MAKE) --dry-run --warn-undefined-variables --makefile=$(firstword $(MAKEFILE_LIST)) all > /dev/null

check-programs:
	$(call check-program,$(IVERILOG))
	$(call check-program,$(VVP))
	$(call check-program,$(VERILATOR))
	$(call check-program,$(YOSYS))

include gen/machina.mk
include syn/machina.mk
include sim/machina.mk

.PHONY: all help check test clean check-makefile check-programs
