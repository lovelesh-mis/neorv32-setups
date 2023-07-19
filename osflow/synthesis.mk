${DEVICE_LIB}-obj08.cf: ${DEVICE_SRC}
	mkdir -p build
	ghdl -a $(GHDL_FLAGS) --workdir=build --work=${DEVICE_LIB} ${DEVICE_SRC}

neorv32-obj08.cf: ${DEVICE_LIB}-obj08.cf ${NEORV32_SRC}
	ghdl -i $(GHDL_FLAGS) --work=neorv32 ${NEORV32_SRC}
	ghdl -m $(GHDL_FLAGS) --work=neorv32 ../neorv32/rtl/core/neorv32_top.vhd

work-obj08.cf: neorv32-obj08.cf ${DESIGN_SRC} ${BOARD_SRC}
	ghdl -i $(GHDL_FLAGS) --work=work ${DESIGN_SRC} ${BOARD_SRC}
	ghdl -m $(GHDL_FLAGS) --work=work ../neorv32/rtl/core/neorv32_top.vhd

ifeq ($(strip $(NEORV32_VERILOG_ALL)),)
READ_VERILOG =
else
READ_VERILOG = read_verilog ${NEORV32_VERILOG_ALL};
endif

${IMPL}.json: work-obj08.cf $(NEORV32_VERILOG_ALL)
	$(YOSYS) $(YOSYSFLAGS) \
	  -p \
	  "$(GHDLSYNTH) $(GHDL_FLAGS) --no-formal $(TOP); \
	  $(READ_VERILOG) synth_${YOSYSSYNTH} \
	  -top $(TOP) $(YOSYSPIPE) \
	  -json $@" 2>&1 | tee yosys-report.txt
