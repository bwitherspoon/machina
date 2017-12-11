dat_dir := $(dir $(lastword $(MAKEFILE_LIST)))

all: all-dat

clean: clean-dat

all-dat:

clean-dat:
	-$(RM) -r $(dat_dir)*.dat

$(dat_dir)%.dat: FUNCT ?= random
$(dat_dir)%.dat: WIDTH ?= 8
$(dat_dir)%.dat: DEPTH ?= 4096
$(dat_dir)%.dat: SCALE ?= 256
$(dat_dir)%.dat: $(dev_mem)
	$< -f $(FUNCT) -w $(WIDTH) -d $(DEPTH) -s $(SCALE) > $@

include $(filter-out $(lastword $(MAKEFILE_LIST)),$(wildcard $(dat_dir)*.mk))

.PHONY: all clean all-dat clean-dat
