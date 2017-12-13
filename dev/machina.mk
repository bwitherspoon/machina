dev_dir := $(dir $(lastword $(MAKEFILE_LIST)))
dev_src_dir := $(dev_dir)src/
dev_mem := $(dev_dir)mem

CXXFLAGS := -std=c++11 -Wall -Wextra
ifdef DEBUG
CXXFLAGS += -O0 -g
endif

vpath %.cc $(dev_src_dir)
vpath %.hh $(dev_src_dir)

all: all-dev

clean: clean-dev

all-dev: $(dev_mem)

clean-dev:
	-$(RM) -r $(dev_mem)

$(dev_mem): LDFLAGS += -lboost_program_options
$(dev_mem): memory.cc memory.hh sigmoid.hh -lboost_program_options
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $<

.PHONY: all clean all-dev clean-dev
