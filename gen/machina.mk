GENDIR := $(dir $(lastword $(MAKEFILE_LIST)))
SRCDIR := $(GENDIR)src/
BINDIR := $(GENDIR)bin/
DATDIR := $(GENDIR)dat/

vpath %.cc $(SRCDIR)
vpath %.h $(SRCDIR)

gen-all: gen-bin gen-dat

gen-bin: $(BINDIR)mem

gen-dat: $(DATDIR)sigmoid.dat $(DATDIR)sigmoid_prime.dat

$(BINDIR) $(DATDIR):
	@mkdir -p $@

$(BINDIR)mem: LDFLAGS += -lboost_program_options
$(BINDIR)mem: driver.cc memory.h sigmoid.h | $(BINDIR)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $<

$(DATDIR)sigmoid.dat: $(BINDIR)mem | $(DATDIR)
	$(PRJDIR)$< -f sigmod -w 8 -d 4096 > $@

$(DATDIR)sigmoid_prime.dat: $(BINDIR)mem | $(DATDIR)
	$(PRJDIR)$< -f sigmod -p -w 6 -d 4096 > $@

gen-clean:
	-$(RM) -r $(BINDIR) $(DATDIR)

clean: gen-clean

.PHONY: gen-all gen-bin gen-dat gen-clean
