TESTS := $(patsubst %.sv,%,$(wildcard *_test.sv))

SVFLAGS = $(DEFINES) -g 2012 -Y .sv -y ../../rtl/

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

%.vcd: DEFINES += -DDUMPFILE=$*.vcd
%.vcd: %.vcd.vvp
	vvp -N $< -vcd

%.lxt: DEFINES += -DDUMPFILE=$*.lxt
%.lxt: %.lxt.vvp
	vvp -N $< -lxt2

%.fst: DEFINES += -DDUMPFILE=$*.fst
%.fst: %.fst.vvp
	vvp -N $< -fst

%.dep: %.sv
	@trap 'rm -f "$@.$$$$"' EXIT; \
	iverilog $(SVFLAGS) -t null -Mall=$@.$$$$ $< > /dev/null 2>&1; \
	sed -i '1i$*.vvp $@:' $@.$$$$; \
	sed -i ':x ; N ; s/\n/ /g ; bx' $@.$$$$; \
	mv -f $@.$$$$ $@

%.vvp %.vcd.vvp %.lxt.vvp %.fst.vvp: %.dep
	iverilog $(SVFLAGS) -t vvp -o $@ $*.sv

clean:
	-$(RM) *.vvp *.vcd *.lx2 *.lxt *.lxt2 *.fst *.dep
