.PHONY: test clean

test: test.vvp
	vvp test.vvp

test.vvp: node.sv test.sv
	iverilog -g2012 -t vvp -o test.vvp node.sv test.sv

clean:
	-$(RM) *.vvp *.vcd
