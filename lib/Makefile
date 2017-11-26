SOURCES := $(wildcard *.sv) $(wildcard *.v)

VERILATOR ?= verilator
IVERILOG ?= iverilog

all:

lint: .lint

.lint: $(SOURCES)
	@for src in $?; do set -e; $(VERILATOR) --lint-only $$src; done
	@for src in $(filter %.sv,$(SOURCES)); \
	do \
		set -e; \
		$(IVERILOG) -Wall -g2012 -tnull -Y.sv -y. $$src; \
	done
	@for src in $(filter %.v,$(SOURCES)); \
	do \
		set -e; \
		$(IVERILOG) -Wall -g2005 -tnull -y. $$src; \
	done
	@touch $@

clean:
	rm -f .lint

.PHONY: all clean lint
