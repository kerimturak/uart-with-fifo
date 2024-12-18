# Makefile for ModelSim simulation with SystemVerilog

# Include paths for RTL and testbench files
RTL_DIR = ./rtl
TB_DIR = ./tb
INC_DIR = $(RTL_DIR)/include

# Suppression options for warnings and errors
SUPPRESS_CMD = -suppress vlog-2583 -suppress vopt-8386 -suppress vlog-2275 -svinputport=relaxed
VLOG_OPTS = -sv ${SUPPRESS_CMD} +acc +incdir+${INC_DIR}

# SystemVerilog source files
TB_FILE = $(TB_DIR)/tb.sv
SV_SOURCES = $(RTL_DIR)/uart_tx.sv $(RTL_DIR)/fifo.sv

# Top level module for simulation
TOP_LEVEL = tb

# Simulation library
LIBRARY = work

# ModelSim commands
VSIM = vsim
VLOG = vlog
VLIB = vlib

# Simulation work directory
WORK_DIR = work

# Default target
all: compile simulate

# Create the work library
$(WORK_DIR):
	$(VLIB) $(WORK_DIR)

# Compile SystemVerilog files
compile: $(WORK_DIR)
	$(VLOG) -work $(WORK_DIR) $(VLOG_OPTS) $(SV_SOURCES) $(TB_FILE)

# Run simulation
simulate: compile
	$(VSIM) $(LIBRARY).$(TOP_LEVEL) -do "questa.do" -t ns

# Clean generated files
clean:
	rm -rf $(WORK_DIR)
	rm -f transcript
	rm -f vsim.wlf
	rm -f modelsim.ini

.PHONY: all compile simulate clean
