/////////////////////////////////////////////////
// Project:   AXI-DMA verification
// Component: AXI-LITE Driver
// Developer: amit.sikder@siliconova.com
// Date:      17.02.2025
// Modified on: 
/////////////////////////////////////////////////

`define SEQ_SP	`uvm_info (get_name(), $sformatf("Start  >>> %s ", get_type_name()), UVM_NONE)
`define SEQ_EP	`uvm_info (get_name(), $sformatf("End  >>> %s ", get_type_name()), UVM_NONE)

class axi4lite_m_base_seq extends uvm_sequence #(axi4lite_m_seq_item);
    `uvm_object_utils(axi4lite_m_base_seq)

    // Fields
    bit [31:0] addr;   // Address for the AXI-Lite transaction
    bit [31:0] data;   // Data to be written or read
    bit [3:0]  strb;    // AXI-Lite write strobes (for write operations)
    bit [2:0]  prot;    // Protection bits (AWPROT for write and ARPROT for read)
    
    bit READ, WRITE;   // WRITE = 1 --> write, READ = 1 --> read

    // Constructor
    function new(string name = "axi4lite_m_base_seq");
        super.new(name);
    endfunction

    // Body task
    virtual task body();
        `uvm_info(get_name(), $sformatf("Running Base sequence from base Seq"), UVM_HIGH);
    endtask

endclass

class axi4lite_m_reset_seq extends axi4lite_m_base_seq;
    `uvm_object_utils(axi4lite_m_reset_seq)

    axi4lite_m_seq_item item;

    // Constructor
    function new(string name = "axi4lite_m_reset_seq");
        super.new(name);
    endfunction

    // Body task
    virtual task body();
        // Send the reset sequence item to the driver
        `uvm_do_with(item, {item.rst_n == 0;})
    endtask
endclass

class axi4lite_m_write_seq extends axi4lite_m_base_seq;
    `uvm_object_utils(axi4lite_m_write_seq)

    axi4lite_m_seq_item item;

    // Constructor
    function new(string name = "axi4lite_m_write_seq");
        super.new(name);
    endfunction

    // Body task
    virtual task body();
        `SEQ_SP
        // Send the transaction to the driver
        `uvm_do_with(item, {item.rst_n == 1;
                            item.WRITE == 1; 
                            item.READ  == 0; 
                            item.dma_s_awaddr == local::addr;
                            item.dma_s_awprot == local::prot;
                            item.dma_s_wdata  == local::data;
                            item.dma_s_wstrb  == local::strb;
        })
        `SEQ_EP
    endtask
endclass

class axi4lite_m_read_seq extends axi4lite_m_base_seq;
    `uvm_object_utils(axi4lite_m_read_seq)

    axi4lite_m_seq_item item;

    // Constructor
    function new(string name = "axi4lite_m_read_seq");
        super.new(name);
    endfunction

    // Body task
    virtual task body();
        `SEQ_SP
        // Send the transaction to the driver
        `uvm_do_with(item, {item.rst_n == 1;
                            item.READ  == 1; 
                            item.WRITE == 0;
                            item.dma_s_araddr == local::addr;
                            item.dma_s_arprot == local::prot;
        })
        `SEQ_EP
    endtask
endclass

