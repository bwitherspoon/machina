syn_dir := $(dir $(lastword $(MAKEFILE_LIST)))
syn_src_dir := $(syn_dir)src/
syn_inc_dir := $(syn_dir)inc/
syn_dep_dir := $(syn_dir)dep/
syn_blif_dir := $(syn_dir)blif/

syn_src := $(notdir $(wildcard $(syn_src_dir)*.v))
syn_inc := $(notdir $(wildcard $(syn_inc_dir)*.vh))
syn_tgt := $(syn_src:.v=)
syn_chk_tgt := $(addprefix check-,$(syn_tgt))
syn_blif_tgt := $(addprefix $(syn_blif_dir),$(syn_tgt:=.blif))

IVERILOG_FLAGS += -y$(syn_src_dir) -I$(syn_inc_dir)
VERILATOR_FLAGS += -y $(syn_src_dir) -I$(syn_inc_dir)

vpath %.v $(syn_src_dir)
vpath %.vh $(syn_inc_dir)

all: all-syn

check: check-syn

clean: clean-syn

all-syn: $(syn_blif_tgt)

check-syn: $(syn_chk_tgt)

clean-syn:
	-$(RM) -r $(syn_dep_dir) $(syn_blif_dir)

$(syn_dep_dir) $(syn_blif_dir):
	@mkdir -p $@

$(syn_chk_tgt):: check-%: %.v
	@$(IVERILOG) -g2005 $(IVERILOG_FLAGS) -tnull $<
	@$(VERILATOR) $(VERILATOR_FLAGS) --unused-regexp nc --lint-only $<
	@$(YOSYS) $(YOSYS_FLAGS) $<

$(syn_blif_dir)sigmoid.blif: $(gen_sig_act) $(gen_sig_der)

$(syn_blif_dir)%.blif: %.v | $(syn_blif_dir)
	@if [ -e '$(syn_dir)$*.ys' ]; then \
		echo '$(YOSYS) $(YOSYS_FLAGS) -l $(syn_blif_dir)$*.log -o $@ -s $(syn_dir)$*.ys'; \
		$(YOSYS) $(YOSYS_FLAGS) -l $(syn_blif_dir)$*.log -o $@ -s $(syn_dir)$*.ys; \
	else \
		echo '$(YOSYS) $(YOSYS_FLAGS) -l $(syn_blif_dir)$*.log -o $@ -S $(filter %.v,$^)'; \
		$(YOSYS) $(YOSYS_FLAGS) -l $(syn_blif_dir)$*.log -o $@ -S $(filter %.v,$^); \
	fi

$(syn_dep_dir)%.mk:: %.v | $(syn_dep_dir)
	@trap 'rm -f $@.$$$$' EXIT; \
	trap '[ -e "$(@:.mk=.log)" ] && cat "$(@:.mk=.log)" 1>&2; rm -f $@' ERR; \
	set -e; \
	$(IVERILOG) -g2005 $(IVERILOG_FLAGS) -tnull -Mall=$@.$$$$ $< > $(@:.mk=.log) 2>&1; \
	basename -a `uniq $@.$$$$` | sed '1i$(syn_blif_dir)$*.blif $@:' | sed ':x;N;s/\n/ /;bx' > $@
	@$(RM) $(@:.mk=.log)

ifneq ($(MAKECMDGOALS),clean)
include $(syn_src:%.v=$(syn_dep_dir)%.mk)
endif

.PHONY: all check clean all-syn check-syn clean-syn $(syn_chk_tgt)
