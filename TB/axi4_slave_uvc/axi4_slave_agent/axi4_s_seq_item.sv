`include "uvm_macros.svh"
import uvm_pkg::*;

class axi4_s_seq_item extends uvm_sequence_item;
    
    rand reg rst_n;
     
     // Common fields for AXI Master 
    rand bit [31:0] dma_m_awaddr;   // Write address
    rand bit [3:0] dma_m_awid;      // Write transaction ID
    rand bit [7:0] dma_m_awlen;     // Burst length
    rand bit [2:0] dma_m_awsize;    // Burst size
    rand bit [1:0] dma_m_awburst;   // Burst type
    rand bit dma_m_awlock;          // Lock type
    rand bit [3:0] dma_m_awcache;   // Cache type
    rand bit [2:0] dma_m_awprot;    // Protection type
    rand bit [3:0] dma_m_awqos;     // Quality of service
    rand bit [3:0] dma_m_awregion;  // Region
    rand bit [3:0] dma_m_awuser;    // User-defined signals
    rand bit dma_m_awvalid;         // Write address valid
         bit dma_m_awready;         // Write address ready

    rand bit dma_m_wlast;           // Write last (end of burst)
    rand bit [31:0] dma_m_wdata;    // Write data
    rand bit [3:0] dma_m_wstrb;     // Write strobes
    rand bit dma_m_wvalid;          // Write valid
         bit dma_m_wready;          // Write ready
    rand bit [3:0] dma_m_wuser;     // Write user data

    rand bit dma_m_bready;          // Write response ready
    rand bit [3:0] dma_m_bid;       // Write transaction ID
         bit [1:0] dma_m_bresp;     // Write response (ACK or ERROR)
    rand bit [3:0] dma_m_buser;     // Write user response
         bit dma_m_bvalid;          // Write response valid

    rand bit [31:0] dma_m_araddr;   // Read address
    rand bit [3:0] dma_m_arid;      // Read transaction ID
    rand bit [7:0] dma_m_arlen;     // Burst length
    rand bit [2:0] dma_m_arsize;    // Burst size
    rand bit [1:0] dma_m_arburst;   // Burst type
    rand bit dma_m_arlock;          // Lock type
    rand bit [3:0] dma_m_arcache;   // Cache type
    rand bit [2:0] dma_m_arprot;    // Protection type
    rand bit [3:0] dma_m_arqos;     // Quality of service
    rand bit [3:0] dma_m_arregion;  // Region
    rand bit [3:0] dma_m_aruser;    // User-defined signals
    rand bit dma_m_arvalid;         // Read address valid
         bit dma_m_arready;         // Read address ready

         bit [31:0] dma_m_rdata;    // Read data
    rand bit [3:0] dma_m_rid;       // Read transaction ID
         bit [1:0] dma_m_rresp;     // Read response (ACK or ERROR)
    rand bit dma_m_rlast;           // Read last (end of burst)
    rand bit dma_m_rvalid;          // Read valid
         bit dma_m_rready;          // Read ready
    rand bit [3:0] dma_m_ruser;     // Read user data

    bit READ, WRITE;                //user defined variable to control read-write operation
    bit[31:0] assoc_array [int];

    // Factory registration
    `uvm_object_utils_begin(axi4_s_seq_item)
        `uvm_field_int(dma_m_awaddr, UVM_ALL_ON)
        `uvm_field_int(dma_m_awid, UVM_ALL_ON)
        `uvm_field_int(dma_m_awlen, UVM_ALL_ON)
        `uvm_field_int(dma_m_awsize, UVM_ALL_ON)
        `uvm_field_int(dma_m_awburst, UVM_ALL_ON)
        `uvm_field_int(dma_m_awlock, UVM_ALL_ON)
        `uvm_field_int(dma_m_awcache, UVM_ALL_ON)
        `uvm_field_int(dma_m_awprot, UVM_ALL_ON)
        `uvm_field_int(dma_m_awqos, UVM_ALL_ON)
        `uvm_field_int(dma_m_awregion, UVM_ALL_ON)
        `uvm_field_int(dma_m_awuser, UVM_ALL_ON)
        
        `uvm_field_int(dma_m_wdata, UVM_ALL_ON)
        `uvm_field_int(dma_m_wstrb, UVM_ALL_ON)
        `uvm_field_int(dma_m_wuser, UVM_ALL_ON)
        
        `uvm_field_int(dma_m_bid, UVM_ALL_ON)
        `uvm_field_int(dma_m_buser, UVM_ALL_ON)

        `uvm_field_int(dma_m_araddr, UVM_ALL_ON)
        `uvm_field_int(dma_m_arid, UVM_ALL_ON)
        `uvm_field_int(dma_m_arlen, UVM_ALL_ON)
        `uvm_field_int(dma_m_arsize, UVM_ALL_ON)
        `uvm_field_int(dma_m_arburst, UVM_ALL_ON)
        `uvm_field_int(dma_m_arlock, UVM_ALL_ON)
        `uvm_field_int(dma_m_arcache, UVM_ALL_ON)
        `uvm_field_int(dma_m_arprot, UVM_ALL_ON)
        `uvm_field_int(dma_m_arqos, UVM_ALL_ON)
        `uvm_field_int(dma_m_arregion, UVM_ALL_ON)
        `uvm_field_int(dma_m_aruser, UVM_ALL_ON)
        
        `uvm_field_int(dma_m_rid, UVM_ALL_ON)
        `uvm_field_int(dma_m_ruser, UVM_ALL_ON)
        `uvm_field_int(dma_m_rlast, UVM_ALL_ON)

    `uvm_object_utils_end

    // Constructor
    function new(string name = "axi4_s_seq_item");
        super.new(name);
    endfunction

endclass
