VPATH = ../rtl

.PHONY: test clean
.SECONDARY: %.vvp

test: logistic_test.vcd

%.vcd: %.vvp
	vvp $<

%.vvp: %.sv
	iverilog -g2012 -Y .sv -y ../../rtl -t vvp -o $@ $<

clean:
	-$(RM) *.vvp *.vcd
