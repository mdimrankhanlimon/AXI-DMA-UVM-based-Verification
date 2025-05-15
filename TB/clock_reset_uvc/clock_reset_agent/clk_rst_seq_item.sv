`include "uvm_macros.svh"
 import uvm_pkg::* ; 

class clk_rst_seq_item extends uvm_sequence_item;

	// field 
    int reset;
	int frequency;
	int clk_enb;
	int clk_ctrl;

	`uvm_object_utils_begin(clk_rst_seq_item)
		`uvm_field_int (reset, UVM_ALL_ON)
	`uvm_object_utils_end
	
	// constructor
	function new (string name = "clk_rst_seq_item");
		super.new(name);
	endfunction

endclass

