VERILATOR ?= verilator
IVERILOG ?= iverilog

all: test lint

test:
	@for src in $(wildcard *.sv); \
	do \
		set -e; \
		$(IVERILOG) -Wall -g2012 -tnull -Y.sv -y. $$src; \
	done
	@for src in $(wildcard *.v); \
	do \
		set -e; \
		$(IVERILOG) -Wall -g2005 -tnull -y. $$src; \
	done

lint:
	@for src in $(wildcard *.sv) $(wildcard *.v); do set -e; $(VERILATOR) --lint-only $$src; done

clean:

.PHONY: all test lint clean
