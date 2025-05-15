`include "axi4lite_master_if.sv"

package axi4lite_master_pkg;
	//`include "uvm_macros.svh"
	//import uvm_pkg::* ;

	`include "axi4lite_m_seq_item.sv"
	`include "axi4lite_m_seq_lib.sv"
	`include "axi4lite_m_driver.sv"
	`include "axi4lite_m_monitor.sv"
	//`include "axi4lite_m_coverage.sv"
	`include "axi4lite_m_agent_config.sv"
	`include "axi4lite_m_agent.sv"
endpackage
