dat_dir := dat/
dep_dir := dep/

dat_sig_act := $(dat_dir)sigmoid_act.dat
dat_sig_der := $(dat_dir)sigmoid_der.dat

define depends
	@trap 'rm -f $@.$$$$' EXIT; \
	trap 'echo "ERROR: unable to generate dependencies for $<"; \
		[ -e "$(@:.mk=.log)" ] && cat "$(@:.mk=.log)" | sed "s,^,$(@:.mk=.log): ," 1>&2; \
		rm -f $@' ERR; \
	set -e; \
	$(IVERILOG) -g2012 $(IVERILOG_FLAGS) -tnull -Mall=$@.$$$$ $< >$(@:.mk=.log) 2>&1; \
	basename -a `uniq $@.$$$$` | sed '1i$(1) $@:' | sed ':x;N;s/\n/ /;bx' >$@
	@$(RM) $(@:.mk=.log)
endef

all: all-dat

clean: clean-dat clean-dep

all-dat: $(dat_sig_act) $(dat_sig_der)

clean-dat:
	-$(RM) -r $(dat_dir)

clean-dep:
	-$(RM) -r $(dep_dir)

$(dat_dir) $(dep_dir):
	@mkdir $@

$(dat_sig_act): FUNCT = sigmoid
$(dat_sig_act): WIDTH = 8
$(dat_sig_act): DEPTH = 4096
$(dat_sig_act): SCALE = 255

$(dat_sig_der): FUNCT = sigmoid-prime
$(dat_sig_der): WIDTH = 7
$(dat_sig_der): DEPTH = 4096
$(dat_sig_der): SCALE = 255

$(dat_dir)%.dat: FUNCT ?= random
$(dat_dir)%.dat: WIDTH ?= 8
$(dat_dir)%.dat: DEPTH ?= 4096
$(dat_dir)%.dat: SCALE ?= 256
$(dat_dir)%.dat: dev/mem | $(dat_dir)
	$< -f $(FUNCT) -w $(WIDTH) -d $(DEPTH) -s $(SCALE) > $@

.PHONY: all clean all-dat clean-dat clean-dep
