prj_dir ?= ../
dat_dir := $(dir $(lastword $(MAKEFILE_LIST)))
dat_cur := $(notdir $(lastword $(MAKEFILE_LIST)))
dat_inc := $(filter-out $(dat_dir)$(dat_cur),$(wildcard $(dat_dir)*.mk))

all: all-dat

clean: clean-dat

all-dat:

clean-dat:
	-$(RM) -r $(dat_dir)*.dat

$(dat_dir)%.dat: FUNCT ?= random
$(dat_dir)%.dat: WIDTH ?= 8
$(dat_dir)%.dat: DEPTH ?= 4096
$(dat_dir)%.dat: SCALE ?= 256
$(dat_dir)%.dat: $(prj_dir)dev/bin/mem
	$< -f $(FUNCT) -w $(WIDTH) -d $(DEPTH) -s $(SCALE) > $@

include $(dat_inc)

.PHONY: all clean all-dat clean-dat
