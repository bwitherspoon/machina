syn_dir := $(dir $(lastword $(MAKEFILE_LIST)))
syn_src_dir := $(syn_dir)src/
syn_cfg_dir := $(syn_dir)cfg/
syn_gen_dir := $(syn_dir)gen/

syn_src := $(notdir $(wildcard $(syn_src_dir)*.v))
syn_dep := $(addprefix $(dep_dir),$(syn_src:.v=.mk))
syn_gen := $(addprefix $(syn_gen_dir),$(syn_src))
syn_chk := $(addprefix check-,$(syn_src:.v=))
syn_lnt := $(addprefix lint-,$(syn_src:.v=))

IVERILOG_FLAGS += -y$(syn_src_dir:/=)
VERILATOR_FLAGS += -y $(syn_src_dir:/=)

vpath %.v $(syn_src_dir)

all: all-syn

check: check-syn

lint: lint-syn

clean: clean-syn

all-syn: $(syn_gen)

check-syn: $(syn_chk)

lint-syn: $(syn_lnt)

clean-syn::
	-$(RM) -r $(syn_gen_dir)

$(syn_gen_dir):
	@mkdir -p $@

$(syn_chk):: check-%: %.v
	@$(IVERILOG) -g2005 $(IVERILOG_FLAGS) -tnull $<

$(syn_lnt):: lint-%: %.v
	@$(VERILATOR) $(VERILATOR_FLAGS) --unused-regexp nc --lint-only $<

$(syn_gen_dir)%.blif: %.v | $(syn_gen_dir)
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:=.log) -o $@ -S $(filter %.v,$^)

$(syn_gen_dir)%.v: $(syn_gen_dir)%.blif
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:=.log) -p 'read_blif $<; write_verilog $@'

$(syn_dep): $(dep_dir)%.mk: %.v | $(dep_dir)
	$(call depends,$(syn_gen_dir)$*.blif)

ifeq ($(findstring clean,$(MAKECMDGOALS)),)
-include $(syn_dep)
endif

include $(syn_src_dir)*/*.mk

.PHONY: all check lint clean all-syn check-syn lint-syn clean-syn
.PHONY: $(syn_chk) $(syn_lnt)
