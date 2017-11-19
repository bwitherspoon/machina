SOURCES = $(wildcard *.sv) $(wildcard *.v)

all:

lint: .lint

.lint: $(SOURCES)
	@for src in $?; do verilator --lint-only $$src; done
	@touch $@

clean:
	rm -f .lint

.PHONY: all clean lint
