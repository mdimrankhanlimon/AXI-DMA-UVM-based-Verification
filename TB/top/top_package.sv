package top_pkg;
    `include "uvm_macros.svh"

    import uvm_pkg::* ;
    import clk_rst_pkg::* ;
    import axi4lite_master_pkg::* ;
    import axi4_slave_pkg::* ;
	
	`include "axi_dma_cfg.sv"
    `include "scoreboard.sv"
	`include "functional_coverage.sv"
    `include "environment_config.sv"
    `include "environment.sv"
    `include "../tests/base_test.sv"
    `include "../axi4lite_master_uvc/axi4lite_master_sequences/axi4lite_master_sequence_library.sv"
    `include "../axi4_slave_uvc/axi4_slave_sequences/axi4_slave_sequence_library.sv"
    `include "../clock_reset_uvc/clock_reset_sequences/sequence_library.sv"//clock_reset_sequence_library
    `include "../tests/test_library.sv"

endpackage
