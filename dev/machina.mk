dev_dir := $(dir $(lastword $(MAKEFILE_LIST)))
dev_src_dir := $(dev_dir)src/
dev_bin_dir := $(dev_dir)bin/

ifdef DEBUG
dev_cxx_opt := -O0 -g
else
dev_cxx_opt := -O2
endif
dev_cxx_std := -std=c++11
dev_cxx_wrn := -Wall -Wextra
dev_cxx_inc := -I$(dev_src_dir:/=)

override CXXFLAGS += $(dev_cxx_opt) $(dev_cxx_std) $(dev_cxx_wrn) $(dev_cxx_inc)
LDFLAGS ?=

vpath %.cc $(dev_src_dir:/=)
vpath %.hh $(dev_src_dir:/=)

all: all.dev

clean: clean.dev

all.dev: $(dev_bin_dir)mem $(dev_bin_dir)ice

clean.dev:
	-$(RM) -r $(dev_bin_dir)

$(dev_bin_dir):
	@mkdir -p $@

$(dev_bin_dir)ice: serial.cc serial.hh

$(dev_bin_dir)mem: LDFLAGS += -lboost_program_options
$(dev_bin_dir)mem: memory.hh sigmoid.hh -lboost_program_options

$(dev_bin_dir)%: %.cc | $(dev_bin_dir)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(filter %.cc,$^)

.PHONY: all clean all.dev clean.dev
