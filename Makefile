PRJDIR := $(dir $(firstword $(MAKEFILE_LIST)))

VERILATOR ?= verilator
YOSYS ?= yosys
IVERILOG ?= iverilog
VVP ?= vvp

IVERILOG_VFLAGS := -g2005
IVERILOG_SVFLAGS := -g2012 -Y.sv
IVERILOG_FLAGS := -Wall
ifndef DEBUG
IVERILOG_FLAGS += -DNDEBUG
endif
ifdef NSTOP
IVERILOG_FLAGS += -DNSTOP
endif
VERILATOR_FLAGS := -Wall
CXXFLAGS := -Wall -std=c++11

all: gen-all

include gen/machina.mk
include sim/machina.mk
include syn/machina.mk

.PHONY: all
