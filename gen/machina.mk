GENDIR := $(dir $(lastword $(MAKEFILE_LIST)))

vpath %.cc $(GENDIR)
vpath %.h $(GENDIR)

MEMGEN_SOURCES := driver.cc
MEMGEN_HEADERS := memory.h sigmoid.h

all: all-gen

test: test-gen

clean: clean-gen

all-gen: memgen

test-gen: test-memgen

memgen: LDFLAGS += -lboost_program_options
memgen: $(MEMGEN_SOURCES) $(MEMGEN_HEADERS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(filter %.cc,$<)

test-memgen:
	@echo ""
	@echo "  Passed \"make $@\""
	@echo ""

clean-gen:
	-$(RM) memgen

.PHONY: all-gen test-gen clean-gen
