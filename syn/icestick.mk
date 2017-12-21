syn_ice_dir := $(syn_dir)ice/

ICEDEV ?= hx1k
ICEDB ?= /usr/share/icestorm/chipdb-1k.txt

ARACHNE_PNR ?= arachne-pnr
ARACHNE_PNR_OPTIONS := -q -d $(subst hx,,$(subst lx,,$(ICEDEV)))
ICEPACK ?= icepack
ICEPROG ?= iceprog
ICETIME ?= icetime
ICETIME_OPTIONS := -d $(ICEDEV) -C $(ICEDB) -m -t

all: all-syn

clean: clean-syn

all-syn: all-ice

all-ice: $(syn_ice_dir)icestick.asc \
			   $(syn_ice_dir)icestick.bin \
				 $(syn_ice_dir)icestick.rpt

clean-syn::
	-$(RM) -r $(syn_ice_dir)

$(syn_ice_dir):
	@mkdir -p $@

$(syn_ice_dir)%.blif: %.v | $(syn_ice_dir)
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:=.log) -p 'synth_ice40 -blif $@' $^

$(syn_ice_dir)%.v: $(syn_ice_dir)%.blif
	$(YOSYS) $(YOSYS_FLAGS) -l $(@:=.log) -p 'read_blif $<; write_verilog $@'

$(syn_ice_dir)%.asc: $(syn_cfg_dir)%.pcf $(syn_ice_dir)%.blif
	$(ARACHNE_PNR) $(ARACHNE_PNR_OPTIONS) -o $@ -p $^

$(syn_ice_dir)%.rpt: $(syn_ice_dir)%.asc
	$(ICETIME) $(ICETIME_OPTIONS) -r $@ $<

$(syn_ice_dir)%.bin: $(syn_ice_dir)%.asc
	$(ICEPACK) $< $@

$(sys_ice_dep): $(dep_dir)%.mk: %.v | $(dep_dir)
	$(call depends,$(syn_ice_dir)$*.blif)

ifeq ($(findstring clean,$(MAKECMDGOALS)),)
include $(sys_ice_dep)
endif

.PHONY: all clean all-syn all-ice clean-syn
