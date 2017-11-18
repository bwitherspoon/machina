VPATH = ../../rtl

TESTS = node_test logistic_test

.PHONY: test clean $(TESTS)
.SECONDARY:

test: $(TESTS)

node_test.vvp: node.sv

logistic_test.vvp: logistic.sv

$(TESTS) : %: %.vvp
	vvp $< -none

%.vcd: %.vvp
	vvp $<

%.vvp: %.sv
	iverilog -g2012 -Y .sv -y ../../rtl -t vvp -o $@ $<

clean:
	-$(RM) *.vvp *.vcd
