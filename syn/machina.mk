syn_dir := $(dir $(lastword $(MAKEFILE_LIST)))
syn_src_dir := $(syn_dir)src/
syn_inc_dir := $(syn_dir)inc/
syn_log_dir := $(syn_dir)log/
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

$(syn_chk_tgt):: check-%: %.v
	@$(IVERILOG) -g2005 $(IVERILOG_FLAGS) -tnull $<
	@$(VERILATOR) $(VERILATOR_FLAGS) --lint-only $<
	@$(YOSYS) $(YOSYS_FLAGS) $<

$(syn_blif_dir)sigmoid.blif: memory.v $(gen_sig_act) $(gen_sig_der)

$(syn_blif_dir)%.blif: %.v | $(syn_blif_dir) $(syn_log_dir)
	@if [ -e '$(syn_dir)$*.ys' ]; then \
		echo '$(YOSYS) $(YOSYS_FLAGS) -l $(syn_log_dir)$*-blif.log -o $@ -s $(syn_dir)$*.ys'; \
		$(YOSYS) $(YOSYS_FLAGS) -l $(syn_log_dir)$*-blif.log -o $@ -s $(syn_dir)$*.ys; \
	else \
		echo '$(YOSYS) $(YOSYS_FLAGS) -l $(syn_log_dir)$*-blif.log -o $@ -S $(filter %.v,$^)'; \
		$(YOSYS) $(YOSYS_FLAGS) -l $(syn_log_dir)$*-blif.log -o $@ -S $(filter %.v,$^); \
	fi

$(syn_blif_dir) $(syn_log_dir):
	@mkdir -p $@

clean-syn:
	-$(RM) -r $(syn_blif_dir) $(syn_log_dir)

.PHONY: all check clean all-syn check-syn clean-syn $(syn_chk_tgt)
