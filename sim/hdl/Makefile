LIBDIR = ../../syn
SRCDIR = .
SOURCE = $(patsubst %.sv,%,$(wildcard $(SRCDIR)/*_tb.sv))
VFLAGS = $(DEFINES) -Wall -g2012 -Y.sv -y$(LIBDIR)

IVERILOG ?= iverilog
VVP ?= vvp

ifdef DEBUG
DEFINES += -DDEBUG
endif

all: $(SOURCE:=.vvp)

test: $(SOURCE)

lint:
	@for src in *.sv; do $(IVERILOG) $(VFLAGS) -tnull $$src; done

$(SOURCE): % : %.vvp
	$(VVP) -N $< -none

%.vcd: %.vcd.vvp
	$(VVP) -N $< -vcd

%.lxt: %.lxt.vvp
	$(VVP) -N $< -lxt2

%.fst: %.fst.vvp
	$(VVP) -N $< -fst

%.vcd.vvp: DEFINES += -DDUMPFILE=$*.vcd
%.lxt.vvp: DEFINES += -DDUMPFILE=$*.lxt
%.fst.vvp: DEFINES += -DDUMPFILE=$*.fst

%.vvp %.vcd.vvp %.lxt.vvp %.fst.vvp:
	$(IVERILOG) $(VFLAGS) -tvvp -o $@ $*.sv

include $(SOURCE:=.dep)

%.dep: %.sv
	@trap 'rm -f "$@.$$$$"' EXIT; \
	$(IVERILOG) $(VFLAGS) -tnull -Mall=$@.$$$$ $< > /dev/null 2>&1; \
	sed -i '1i$*.vvp $@:' $@.$$$$; \
	sed -i ':x ; N ; s/\n/ /g ; bx' $@.$$$$; \
	mv -f $@.$$$$ $@

clean:
	-$(RM) *.vvp *.vcd *.lx2 *.lxt *.lxt2 *.fst *.dep

.PHONY: all test lint clean $(SOURCE)
