syn_dir := $(dir $(lastword $(MAKEFILE_LIST)))
syn_src_dir := $(syn_dir)src/
syn_dep_dir := $(syn_dir)dep/
syn_gen_dir := $(syn_dir)generic/

syn_src := $(notdir $(wildcard $(syn_src_dir)*.v))
syn_tgt := $(syn_src:.v=)
syn_chk_tgt := $(addprefix check-,$(syn_src:.v=))
syn_lnt_tgt := $(addprefix lint-,$(syn_src:.v=))
syn_gen_tgt := $(addprefix $(syn_gen_dir),$(syn_src:.v=.blif))

IVERILOG_FLAGS += -y$(syn_src_dir)
VERILATOR_FLAGS += -y $(syn_src_dir)

vpath %.v $(syn_src_dir)

all: all-syn

check: check-syn

lint: lint-syn

clean: clean-syn

all-syn: $(syn_gen_tgt)

check-syn: $(syn_chk_tgt)

lint-syn: $(syn_lnt_tgt)

clean-syn::
	-$(RM) -r $(syn_dep_dir) $(syn_gen_dir)

$(syn_dep_dir) $(syn_gen_dir):
	@mkdir -p $@

$(syn_chk_tgt):: check-%: %.v
	@$(IVERILOG) -g2005 $(IVERILOG_FLAGS) -tnull $<
	@$(YOSYS) $(YOSYS_FLAGS) $<

$(syn_lnt_tgt):: lint-%: %.v
	@$(VERILATOR) $(VERILATOR_FLAGS) --unused-regexp nc --lint-only $<

$(syn_gen_dir)sigmoid.blif: $(dat_sig_act) $(dat_sig_der)

$(syn_gen_dir)%.blif: %.v | $(syn_gen_dir)
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:.blif=.log) -o $@ -S $(filter %.v,$^)

$(syn_dep_dir)%.mk:: %.v | $(syn_dep_dir)
	$(call generate-depends,$(syn_gen_dir)$*.blif)

ifneq ($(MAKECMDGOALS),clean)
include $(syn_src:%.v=$(syn_dep_dir)%.mk)
endif

.PHONY: all check lint clean all-syn check-syn lint-syn clean-syn
.PHONY: $(syn_chk_tgt) $(syn_lnt_tgt)
