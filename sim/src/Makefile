.PHONY: all clean

all:
	verilator -Wall --trace -Mdir obj --cc ../../rtl/node.sv --exe ./main.cpp
	make -C obj -f Vnode.mk Vnode

clean:
	-$(RM) -r obj *.vcd
