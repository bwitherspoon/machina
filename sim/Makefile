.PHONY: all clean

all:
	verilator -Wall --trace --cc ../rtl/node.sv --exe ./main.cpp
	make -C obj_dir -f Vnode.mk Vnode

clean:
	-$(RM) -r obj_dir *.vcd
