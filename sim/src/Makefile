.PHONY: all clean

all:
	verilator -Wall --trace -Mdir obj --cc ../../rtl/associate.sv --exe ./main.cpp
	make -C obj -f Vassociate.mk Vassociate

clean:
	-$(RM) -r obj *.vcd
