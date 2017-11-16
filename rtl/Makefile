.PHONY: test clean
.SECONDARY: test.vvp

test: test.vcd

%.vcd: %.vvp
	vvp $<

%.vvp: %.sv node.sv
	iverilog -g2012 -t vvp -o $@ $^

clean:
	-$(RM) *.vvp *.vcd
