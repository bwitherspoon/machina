LIBDIR = ../../lib
SRCDIR = .
SOURCE = $(patsubst %.sv,%,$(wildcard $(SRCDIR)/*_test.sv))
VFLAGS = $(DEFINES) -Wall -g2012 -Y.sv -y$(LIBDIR)

IVERILOG ?= iverilog
VVP ?= vvp

ifdef DEBUG
DEFINES += -DDEBUG
endif

.PHONY: all test clean $(SOURCE)

.DELETE_ON_ERROR:

all: $(SOURCE:=.vvp)

test: $(SOURCE)

include $(SOURCE:=.dep)

$(SOURCE): % : %.vvp
	$(VVP) -N $< -none

%.vcd: %.vcd.vvp
	$(VVP) -N $< -vcd

%.lxt: %.lxt.vvp
	$(VVP) -N $< -lxt2

%.fst: %.fst.vvp
	$(VVP) -N $< -fst

%.vcd.vvp: DEFINES += -DDUMPFILE=$*.vcd
%.lxt.vvp: DEFINES += -DDUMPFILE=$*.lxt
%.fst.vvp: DEFINES += -DDUMPFILE=$*.fst

%.vvp %.vcd.vvp %.lxt.vvp %.fst.vvp: %.dep
	$(IVERILOG) $(VFLAGS) -t vvp -o $@ $*.sv

%.dep: %.sv
	@trap 'rm -f "$@.$$$$"' EXIT; \
	$(IVERILOG) $(VFLAGS) -t null -Mall=$@.$$$$ $< > /dev/null 2>&1; \
	sed -i '1i$*.vvp $@:' $@.$$$$; \
	sed -i ':x ; N ; s/\n/ /g ; bx' $@.$$$$; \
	mv -f $@.$$$$ $@

clean:
	-$(RM) *.vvp *.vcd *.lx2 *.lxt *.lxt2 *.fst *.dep
