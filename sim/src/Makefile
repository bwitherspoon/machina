.PHONY: all clean

all:
	verilator -Wall --trace -Mdir obj --cc ../../rtl/product.sv --exe ./main.cpp
	make -C obj -f Vproduct.mk Vproduct

clean:
	-$(RM) -r obj *.vcd
