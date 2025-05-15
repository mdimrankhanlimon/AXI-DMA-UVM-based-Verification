`include "uvm_macros.svh"
import uvm_pkg::*;

class axi4lite_m_seq_item extends uvm_sequence_item;
    
    bit clk;
    rand reg rst_n;
    
    // Write Address Channel
    rand bit [31:0] dma_s_awaddr;
	rand bit [2:0] dma_s_awprot;
    rand bit dma_s_awvalid;
         bit dma_s_awready;

    // Write Data Channel
    rand bit [31:0] dma_s_wdata;
    rand bit [3:0] dma_s_wstrb;
    rand bit dma_s_wvalid;
         bit dma_s_wready;
	rand bit dma_s_wlast;

    // Write Response Channel
         bit [1:0] dma_s_bresp;
         bit dma_s_bvalid;
    rand bit dma_s_bready;

    // Read Address Channel
    rand bit [31:0] dma_s_araddr;
	rand bit [2:0] dma_s_arprot;
    rand bit dma_s_arvalid;
         bit dma_s_arready;

    // Read Data Channel
         bit [31:0] dma_s_rdata;
         bit [1:0] dma_s_rresp;
         bit dma_s_rvalid;
    rand bit dma_s_rready;
	     bit dma_s_rlast;

    // variabes to control read-write transaction
        rand bit READ, WRITE;


	bit    dma_done_o;
    bit    dma_error_o;


    // Factory registration
    `uvm_object_utils_begin(axi4lite_m_seq_item)
        `uvm_field_int(dma_s_awaddr, UVM_ALL_ON)
		`uvm_field_int(dma_s_awprot, UVM_ALL_ON)
        //`uvm_field_int(dma_s_awvalid, UVM_ALL_ON)
        `uvm_field_int(dma_s_wdata, UVM_ALL_ON)
        `uvm_field_int(dma_s_wstrb, UVM_ALL_ON)
        //`uvm_field_int(dma_s_wvalid, UVM_ALL_ON)
		//`uvm_field_int(dma_s_wlast, UVM_ALL_ON)
        //`uvm_field_int(dma_s_bready, UVM_ALL_ON)
        `uvm_field_int(dma_s_araddr, UVM_ALL_ON)
		`uvm_field_int(dma_s_arprot, UVM_ALL_ON)
        `uvm_field_int(dma_s_rdata, UVM_ALL_ON)
        //`uvm_field_int(dma_s_rready, UVM_ALL_ON)
        //`uvm_field_int(dma_s_bresp, UVM_ALL_ON)
        //`uvm_field_int(dma_s_rresp, UVM_ALL_ON)

        `uvm_field_int(READ, UVM_ALL_ON)
        `uvm_field_int(WRITE, UVM_ALL_ON)

		`uvm_field_int(dma_done_o, UVM_ALL_ON)
        `uvm_field_int(dma_error_o, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi4lite_m_seq_item");
        super.new(name);
    endfunction
endclass
