GEN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
GEN_SRC_DIR := $(GEN_DIR)src/
GEN_BIN_DIR := $(GEN_DIR)bin/
GEN_DAT_DIR := $(GEN_DIR)dat/

vpath %.cc $(GEN_SRC_DIR)
vpath %.h $(GEN_SRC_DIR)

gen: gen-bin gen-dat

gen-bin: $(GEN_BIN_DIR)mem

gen-dat: $(GEN_DAT_DIR)sigmoid_activ.dat $(GEN_DAT_DIR)sigmoid_deriv.dat

$(GEN_BIN_DIR) $(GEN_DAT_DIR):
	@mkdir -p $@

$(GEN_BIN_DIR)mem: LDFLAGS += -lboost_program_options
$(GEN_BIN_DIR)mem: driver.cc memory.h sigmoid.h | $(GEN_BIN_DIR)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $<

$(GEN_DAT_DIR)sigmoid_activ.dat: FUNCT = sigmoid
$(GEN_DAT_DIR)sigmoid_activ.dat: WIDTH = 8
$(GEN_DAT_DIR)sigmoid_activ.dat: DEPTH = 4096
$(GEN_DAT_DIR)sigmoid_activ.dat: SCALE = 255

$(GEN_DAT_DIR)sigmoid_deriv.dat: FUNCT = sigmoid-prime
$(GEN_DAT_DIR)sigmoid_deriv.dat: WIDTH = 7
$(GEN_DAT_DIR)sigmoid_deriv.dat: DEPTH = 4096
$(GEN_DAT_DIR)sigmoid_deriv.dat: SCALE = 255

$(GEN_DAT_DIR)%.dat: FUNCT ?= random
$(GEN_DAT_DIR)%.dat: WIDTH ?= 8
$(GEN_DAT_DIR)%.dat: DEPTH ?= 4096
$(GEN_DAT_DIR)%.dat: SCALE ?= 256
$(GEN_DAT_DIR)%.dat: $(GEN_BIN_DIR)mem | $(GEN_DAT_DIR)
	$(PRJ_DIR)$< -f $(FUNCT) -w $(WIDTH) -d $(DEPTH) -s $(SCALE) > $@

gen-clean:
	-$(RM) -r $(GEN_BIN_DIR) $(GEN_DAT_DIR)

clean: gen-clean

.PHONY: gen gen-all gen-bin gen-dat gen-clean
