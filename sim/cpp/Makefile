TARGET = associate
SOURCE = associate.cpp main.cpp
MODULE = associate.sv
SRCDIR = .
LIBDIR = ../../lib
OBJDIR = ./obj
VFLAGS = -Wall
OPTION = $(VFLAGS) -Mdir $(OBJDIR) -y $(LIBDIR) -o $(TARGET) --trace --cc --exe

all:
	verilator $(OPTION) $(MODULE) $(SOURCE)
	make -C $(OBJDIR) -f V$(TARGET).mk $(TARGET)

clean:
	-$(RM) -r obj *.vcd

.PHONY: all clean
