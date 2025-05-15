TEST_NAME = sample_sanity_test

xelb: 
	@xrun \
			-access +rwc \
			-timescale 1ns/1ps \
			-sv -sysv \
			-UVM \
			-incdir ../RTL/ -f rtl_files.f -incdir ../TB/ -f tb_files.f \
			-snapshot tb_top_snap -createdebugdb \
			-elaborate

xsim: xelb
	@xrun \
			-r tb_top_snap \
			+UVM_TESTNAME=$(TEST_NAME) \
			+UVM_TIMEOUT=8000000 +UVM_VERBOSITY=UVM_HIGH \

xdbg: xelb
	@xrun \
			-r tb_top_snap \
			+UVM_TESTNAME=$(TEST_NAME) \
			-input debug_script.tcl
			#+UVM_TIMEOUT=80000 +UVM_VERBOSITY=UVM_LOW 
			#@mv dump.vcd ./$(TEST_NAME)/

xwave: dump.vcd
	@simvision dump.vcd &

hcln:
	rm -rf *.log  *.pb *.jou xsim.dir *.wdb xrun* xcelium.d dump* waves*
	rm -rf *log
	rm -rf x*
	rm -rf simvision*
	reset
	@ls -ltrh

