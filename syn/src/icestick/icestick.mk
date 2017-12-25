ice_src_dir := $(dir $(lastword $(MAKEFILE_LIST)))
syn_ice_dir := $(syn_dir)ice/
ice_src := icestick.v
ice_dep := $(addprefix $(dep_dir),$(ice_src:.v=.mk))

IVERILOG_FLAGS += -y$(ice_src_dir:/=)
VERILATOR_FLAGS += -y $(ice_src_dir:/=)

ICEDEV ?= hx1k
ICEDB ?= /usr/share/icestorm/chipdb-1k.txt

ARACHNE_PNR ?= arachne-pnr
ARACHNE_PNR_OPTIONS := -q -d $(subst hx,,$(subst lx,,$(ICEDEV)))
ICEPACK ?= icepack
ICEPROG ?= iceprog
ICETIME ?= icetime
ICETIME_OPTIONS := -d $(ICEDEV) -C $(ICEDB) -m -t

vpath %.v $(ice_src_dir)

all.syn: icestick

icestick: $(syn_ice_dir)icestick.asc \
			    $(syn_ice_dir)icestick.bin \
				  $(syn_ice_dir)icestick.rpt

clean.syn::
	-$(RM) -r $(syn_ice_dir)

$(syn_ice_dir):
	@mkdir -p $@

$(syn_ice_dir)%.blif: %.v | $(syn_ice_dir)
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:=.log) -p 'synth_ice40 -blif $@' $^

$(syn_ice_dir)%.v: $(syn_ice_dir)%.blif
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:=.log) -p 'read_blif $<; write_verilog $@'

$(syn_ice_dir)%.asc: $(ice_src_dir)%.pcf $(syn_ice_dir)%.blif
	$(ARACHNE_PNR) $(ARACHNE_PNR_OPTIONS) -o $@ -p $^

$(syn_ice_dir)%.rpt: $(syn_ice_dir)%.asc
	$(ICETIME) $(ICETIME_OPTIONS) -r $@ $<

$(syn_ice_dir)%.bin: $(syn_ice_dir)%.asc
	$(ICEPACK) $< $@

$(ice_dep): $(dep_dir)%.mk: %.v | $(dep_dir)
	$(call depends,$(syn_ice_dir)$*.blif)

ifeq ($(findstring clean,$(MAKECMDGOALS)),)
-include $(ice_dep)
endif

.PHONY: all.syn clean.syn icestick
