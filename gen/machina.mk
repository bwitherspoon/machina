GENDIR := $(dir $(lastword $(MAKEFILE_LIST)))
SRCDIR := $(GENDIR)src/
BINDIR := $(GENDIR)bin/
DATDIR := $(GENDIR)dat/

vpath %.cc $(SRCDIR)
vpath %.h $(SRCDIR)

gen: gen-bin gen-dat

gen-bin: $(BINDIR)mem

gen-dat: $(DATDIR)sigmoid_activ.dat $(DATDIR)sigmoid_deriv.dat

$(BINDIR) $(DATDIR):
	@mkdir -p $@

$(BINDIR)mem: LDFLAGS += -lboost_program_options
$(BINDIR)mem: driver.cc memory.h sigmoid.h | $(BINDIR)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $<

$(DATDIR)sigmoid_activ.dat: FUNCT = sigmoid
$(DATDIR)sigmoid_activ.dat: WIDTH = 8
$(DATDIR)sigmoid_activ.dat: DEPTH = 4096
$(DATDIR)sigmoid_activ.dat: SCALE = 255

$(DATDIR)sigmoid_deriv.dat: FUNCT = sigmoid-prime
$(DATDIR)sigmoid_deriv.dat: WIDTH = 7
$(DATDIR)sigmoid_deriv.dat: DEPTH = 4096
$(DATDIR)sigmoid_deriv.dat: SCALE = 255

$(DATDIR)%.dat: FUNCT ?= random
$(DATDIR)%.dat: WIDTH ?= 8
$(DATDIR)%.dat: DEPTH ?= 4096
$(DATDIR)%.dat: SCALE ?= 256
$(DATDIR)%.dat: $(BINDIR)mem | $(DATDIR)
	$(PRJDIR)$< -f $(FUNCT) -w $(WIDTH) -d $(DEPTH) -s $(SCALE) > $@

gen-clean:
	-$(RM) -r $(BINDIR) $(DATDIR)

clean: gen-clean

.PHONY: gen gen-all gen-bin gen-dat gen-clean
