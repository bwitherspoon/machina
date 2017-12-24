prj := machina
prj_dir := $(dir $(firstword $(MAKEFILE_LIST)))

IVERILOG ?= iverilog
IVERILOG_FLAGS := -Wall -Wno-timescale -Y.sv
ifndef DEBUG
IVERILOG_FLAGS += -DNDEBUG
endif
VVP ?= vvp
VERILATOR ?= verilator
VERILATOR_FLAGS := -Wall
YOSYS ?= yosys
YOSYS_FLAGS := -q

dep_dir := dep/

define depends
	@trap 'rm -f $@.$$$$' EXIT; \
	trap 'echo "ERROR: unable to generate dependencies for $<"; \
		[ -e "$(@:.mk=.log)" ] && cat "$(@:.mk=.log)" | sed "s,^,$(@:.mk=.log): ," 1>&2; \
		rm -f $@' ERR; \
	set -e; \
	$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull -Mall=$@.$$$$ $< >$(@:.mk=.log) 2>&1; \
	basename -a `uniq $@.$$$$` | sed '1i$(1) $@:' | sed ':x;N;s/\n/ /;bx' >$@
	@$(RM) $(@:.mk=.log)
endef

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

clean: clean-dep

check-makefile:
	@$(MAKE) --dry-run --warn-undefined-variables --makefile=$(firstword $(MAKEFILE_LIST)) all > /dev/null

clean-dep:
	-$(RM) -r $(dep_dir)

$(dep_dir):
	@mkdir -p $@

include dev/machina.mk
include inc/machina.mk
include syn/machina.mk
include sim/machina.mk
include dat/machina.mk

.PHONY: all help check test clean check-makefile clean-dep
