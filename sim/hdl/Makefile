VPATH = ../../rtl/

SVFLAGS = $(DEFINES) -g 2012 -Y .sv -y ../../rtl/

TESTS = node_test logistic_test

.PHONY: all test clean $(TESTS)

all: $(TESTS:=.vvp)

test: $(TESTS)

node_test.vvp: node.sv

logistic_test.vvp: logistic.sv

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

%.d: %.sv
	iverilog $(SVFLAGS) -t null -Mall=$@ $<
	sed -i ':a;N;$$!ba;s/\n/ /g' $@

%.vvp %.vcd.vvp %.lxt.vvp %.fst.vvp: %.sv
	iverilog $(SVFLAGS) -t vvp -o $@ $<

clean:
	-$(RM) *.vvp *.vcd *.lx2 *.lxt *.lxt2 *.fst *.d
