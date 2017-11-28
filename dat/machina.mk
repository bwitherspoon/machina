DATDIR := $(dir $(lastword $(MAKEFILE_LIST)))

vpath %.dat $(DATDIR)

clean: dat-clean

$(DATDIR)%_prime.dat: memgen
	$(PRJDIR)$< -p -f $(notdir $*) > $@

$(DATDIR)%.dat: memgen
	$(PRJDIR)$< -f $(notdir $*) > $@

dat-clean:
	-$(RM) $(DATDIR)*.dat

.PHONY: clean dat-clean
