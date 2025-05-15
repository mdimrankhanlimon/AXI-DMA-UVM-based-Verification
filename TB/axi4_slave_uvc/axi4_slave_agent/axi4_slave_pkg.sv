`include "axi4_slave_if.sv"

package axi4_slave_pkg;
	//`include "uvm_macros.svh"
	//import uvm_pkg::* ;

	`include "axi4_s_seq_item.sv"
	`include "axi4_s_driver.sv"
    	`include "axi4_s_monitor.sv"
    	//`include "axi4_s_coverage.sv"
    	`include "axi4_s_agent_config.sv"
	`include "axi4_s_agent.sv"
endpackage
