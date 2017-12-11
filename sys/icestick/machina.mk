sys_ice_dir := $(dir $(lastword $(MAKEFILE_LIST)))
syn_ice_dir := $(syn_dir)ice40/
sys_ice_src := $(notdir $(wildcard $(sys_ice_dir)*.v))
sys_ice_dep := $(addprefix $(dep_dir),$(sys_ice_src:.v=.mk))
sys_ice_dev := hx1k
sys_ice_cdb := /usr/share/icestorm/chipdb-1k.txt

vpath %.v $(sys_ice_dir:/=)
vpath %.pcf $(sys_ice_dir:/=)

ARACHNE_PNR ?= arachne-pnr
ARACHNE_PNR_OPTIONS := -q -d $(subst hx,,$(subst lx,,$(sys_ice_dev)))

ICEPACK ?= icepack
ICEPROG ?= iceprog
ICETIME ?= icetime
ICETIME_OPTIONS := -d $(sys_ice_dev) -C $(sys_ice_cdb) -m -t

all: icestick

clean: clean-sys

icestick: $(sys_ice_dir)icestick.asc $(sys_ice_dir)icestick.bin $(sys_ice_dir)icestick.rpt

clean-sys::
	-$(RM) $(sys_ice_dir)*.{asc,bin,rpt}

clean-syn::
	-$(RM) -r $(syn_ice_dir)

$(syn_ice_dir):
	@mkdir $@

$(syn_ice_dir)%.blif: %.v | $(syn_ice_dir)
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:.blif=.log) -p 'synth_ice40 -blif $@' $^

$(sys_ice_dir)%.asc: %.pcf $(syn_ice_dir)%.blif
	$(ARACHNE_PNR) $(ARACHNE_PNR_OPTIONS) -o $@ -p $^

$(sys_ice_dir)%.rpt: $(sys_ice_dir)%.asc
	$(ICETIME) $(ICETIME_OPTIONS) -r $@ $<

$(sys_ice_dir)%.bin: $(sys_ice_dir)%.asc
	$(ICEPACK) $< $@

$(sys_ice_dep): $(dep_dir)%.mk: %.v | $(dep_dir)
	$(call depends,$(syn_ice_dir)$*.blif)

ifeq ($(findstring clean,$(MAKECMDGOALS)),)
include $(sys_ice_dep)
endif

.PHONY: all clean icestick all-ice clean-sys clean-syn
