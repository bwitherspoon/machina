GENDIR := $(dir $(lastword $(MAKEFILE_LIST)))
SRCDIR := $(GENDIR)src/
BINDIR := $(GENDIR)bin/
DATDIR := $(GENDIR)dat/

vpath %.cc $(SRCDIR)
vpath %.h $(SRCDIR)

gen-all: $(BINDIR)mem $(DATDIR)sigmoid.dat $(DATDIR)sigmoid_prime.dat

$(BINDIR)mem: LDFLAGS += -lboost_program_options
$(BINDIR)mem: driver.cc memory.h sigmoid.h | $(BINDIR)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $<

$(BINDIR) $(DATDIR):
	@mkdir -p $@

$(DATDIR)%_prime.dat: $(BINDIR)mem | $(DATDIR)
	$(PRJDIR)$< -p -f $(notdir $*) > $@

$(DATDIR)%.dat: $(BINDIR)mem | $(DATDIR)
	$(PRJDIR)$< -f $(notdir $*) > $@

clean: gen-clean

gen-clean:
	-$(RM) -r $(BINDIR) $(DATDIR)

.PHONY: clean gen-all gen-clean
