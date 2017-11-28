SYNDIR := $(dir $(lastword $(MAKEFILE_LIST)))

vpath %.v $(SYNDIR)
vpath %.vh $(SYNDIR)

IVERILOG_FLAGS += -y$(SYNDIR) -I$(SYNDIR)
VERILATOR_FLAGS += -y $(SYNDIR) -I$(SYNDIR)

SYN_BASE := $(notdir $(basename $(wildcard $(SYNDIR)*.v)))
SYN_TEST := $(addprefix syn-test-,$(SYN_BASE))
SYN_LINT := $(addprefix syn-lint-,$(SYN_BASE))

syn-all:

test: syn-test

lint: syn-lint

syn-test: $(SYN_TEST)

syn-lint: $(SYN_LINT)

$(SYN_TEST): syn-test-%: %.v
	$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_VFLAGS) -tnull $<
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

$(SYN_LINT): syn-lint-%: %.v
	$(VERILATOR) $(VERILATOR_FLAGS) --lint-only $<
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

.PHONY: test lint syn-all syn-test syn-lint $(SYN_TEST) $(SYN_LINT)
