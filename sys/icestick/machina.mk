sys_ice_dir := $(dir $(lastword $(MAKEFILE_LIST)))
syn_ice_dir := $(syn_dir)ice40/

vpath %.v $(sys_ice_dir)
vpath %.pcf $(sys_ice_dir)

ARACHNE_PNR ?= arachne-pnr
ICEPACK ?= icepack
ICETIME ?= icetime
ICEPROG ?= iceprog

all:

clean: clean-sys

all-ice: $(sys_ice_dir)icestick.asc $(sys_ice_dir)icestick.bin

clean-sys::
	-$(RM) $(sys_ice_dir)*.{bin,blif,asc,rpt,log}

clean-syn::
	-$(RM) -r $(syn_ice_dir)

$(syn_ice_dir):
	@mkdir -p $@

$(syn_ice_dir)icestick.blif: receive.v transmit.v
$(syn_ice_dir)%.blif: %.v | $(syn_ice_dir)
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:.blif=.log) -p 'synth_ice40 -blif $@' $^

$(sys_ice_dir)%.asc: %.pcf $(syn_ice_dir)%.blif
	$(ARACHNE_PNR) -d 1k -o $@ -p $^

$(sys_ice_dir)%.bin: $(sys_ice_dir)%.asc
	$(ICEPACK) $< $@

$(sys_ice_dir)%.rpt: $(sys_ice_dir)%.asc
	$(ICETIME) -d hx1k -mtr $@ $<

.PHONY: all clean all-ice clean-sys clean-syn
