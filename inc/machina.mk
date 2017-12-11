inc_dir := $(dir $(lastword $(MAKEFILE_LIST)))

IVERILOG_FLAGS += -I$(inc_dir:/=)
VERILATOR_FLAGS += -I$(inc_dir:/=)

vpath %.vh $(inc_dir)
vpath %.svh $(inc_dir)
