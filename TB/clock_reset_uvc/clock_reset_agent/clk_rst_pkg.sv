`include "clk_rst_interface.sv"

package clk_rst_pkg;
	//`include "uvm_macros.svh"
	//import uvm_pkg::* ;

	`include "clk_rst_seq_item.sv"
	`include "clk_rst_seq_lib.sv"
	`include "clk_rst_driver.sv"
	`include "clk_rst_agent_config.sv"
	`include "clk_rst_agent.sv"
endpackage
