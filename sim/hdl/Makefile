TESTS := $(patsubst %.sv,%,$(wildcard *_test.sv))

SVFLAGS = $(DEFINES) -Wall -g 2012 -Y .sv -y ../../rtl/

ifdef DEBUG
DEFINES += -DDEBUG
endif

.PHONY: all test clean $(TESTS)

.DELETE_ON_ERROR:

all: $(TESTS:=.vvp)

test: $(TESTS)

include $(TESTS:=.dep)

$(TESTS): % : %.vvp
	vvp -N $< -none

%.vcd: %.vcd.vvp
	vvp -N $< -vcd

%.lxt: %.lxt.vvp
	vvp -N $< -lxt2

%.fst: %.fst.vvp
	vvp -N $< -fst

%.vcd.vvp: DEFINES += -DDUMPFILE=$*.vcd
%.lxt.vvp: DEFINES += -DDUMPFILE=$*.lxt
%.fst.vvp: DEFINES += -DDUMPFILE=$*.fst

%.vvp %.vcd.vvp %.lxt.vvp %.fst.vvp: %.dep
	iverilog $(SVFLAGS) -t vvp -o $@ $*.sv

%.dep: %.sv
	@trap 'rm -f "$@.$$$$"' EXIT; \
	iverilog $(SVFLAGS) -t null -Mall=$@.$$$$ $< > /dev/null 2>&1; \
	sed -i '1i$*.vvp $@:' $@.$$$$; \
	sed -i ':x ; N ; s/\n/ /g ; bx' $@.$$$$; \
	mv -f $@.$$$$ $@

clean:
	-$(RM) *.vvp *.vcd *.lx2 *.lxt *.lxt2 *.fst *.dep
