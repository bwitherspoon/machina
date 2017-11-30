GEN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
GEN_SRC_DIR := $(GEN_DIR)src/
GEN_DAT_DIR := $(GEN_DIR)dat/
GEN_SIG_ACT := $(GEN_DAT_DIR)sigmoid_activ.dat
GEN_SIG_DER := $(GEN_DAT_DIR)sigmoid_deriv.dat
GEN_DAT := $(GEN_SIG_ACT) $(GEN_SIG_DER)
GEN_MEM := $(GEN_DIR)mem

vpath %.cc $(GEN_SRC_DIR)
vpath %.h $(GEN_SRC_DIR)

all:

clean: clean-gen

all-gen: gen-mem gen-dat

clean-gen:
	-$(RM) -r $(GEN_DIR)mem $(GEN_DAT_DIR)

$(GEN_DAT_DIR):
	@mkdir -p $@

gen-mem: $(GEN_MEM)

gen-dat: $(GEN_DAT)

$(GEN_MEM): LDFLAGS += -lboost_program_options
$(GEN_MEM): driver.cc memory.h sigmoid.h -lboost_program_options
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $<

$(GEN_SIG_ACT): FUNCT = sigmoid
$(GEN_SIG_ACT): WIDTH = 8
$(GEN_SIG_ACT): DEPTH = 4096
$(GEN_SIG_ACT): SCALE = 255

$(GEN_SIG_DER): FUNCT = sigmoid-prime
$(GEN_SIG_DER): WIDTH = 7
$(GEN_SIG_DER): DEPTH = 4096
$(GEN_SIG_DER): SCALE = 255

$(GEN_DAT_DIR)%.dat: FUNCT ?= random
$(GEN_DAT_DIR)%.dat: WIDTH ?= 8
$(GEN_DAT_DIR)%.dat: DEPTH ?= 4096
$(GEN_DAT_DIR)%.dat: SCALE ?= 256
$(GEN_DAT_DIR)%.dat: $(GEN_MEM) | $(GEN_DAT_DIR)
	$< -f $(FUNCT) -w $(WIDTH) -d $(DEPTH) -s $(SCALE) > $@

.PHONY: all clean all-gen clean-gen gen-mem gen-dat
