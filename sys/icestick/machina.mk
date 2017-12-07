ice_dir := $(dir $(lastword $(MAKEFILE_LIST)))
ice_src := icestick.v
ice_pin := icestick.pcf

ARACHNE_PNR ?= arachne-pnr
ICEPACK ?= icepack
ICETIME ?= icetime
ICEPROG ?= iceprog

all:

prog: $(ice_dir)icestick.bin
	$(ICEPROG) $<

$(ice_dir)%.asc: $(ice_dir)%.pcf $(syn_blif_dir)%.blif
	$(ARCHNE_PNR) -d 1k -o $@ -p $^

$(ice_dir)%.bin: $(ice_dir)%.asc
	$(ICEPACK) $< $@

$(ice_dir)%.rpt: $(ice_dir)%.asc
	$(ICETIME) -d hx1k -mtr $@ $<

.PHONY: prog
