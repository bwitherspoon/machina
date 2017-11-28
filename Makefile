PRJDIR := $(dir $(firstword $(MAKEFILE_LIST)))

VERILATOR ?= verilator
YOSYS ?= yosys
IVERILOG ?= iverilog
VVP ?= vvp

IVERILOG_VFLAGS := -Wall -g2005
IVERILOG_SVFLAGS := -Wall -g2012 -Y.sv
VERILATOR_VFLAGS := -Wall
CXXFLAGS := -Wall -std=c++11

include gen/machina.mk
include syn/machina.mk
include sim/machina.mk
include dat/machina.mk

all:

test:

clean:

.PHONY: all test clean
