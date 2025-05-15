class axi4lite_m_error_injection_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_error_injection_seq)

  axi4lite_m_write_seq write_seq;
  axi4lite_m_read_seq  read_seq;
 axi4lite_m_reset_seq reset_seq;

  // Constructor
  function new(string name = "axi4lite_m_error_injection_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting Error Injection Sequence", UVM_LOW);

        // reset sequence
        reset_seq = axi4lite_m_reset_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer,this);

    // Set common parameters: non-secure protection and full-word strobe.
    prot = 3'b010;
    strb = 4'b1111;
    WRITE = 1;
    READ  = 0;

        // -------------------------------------------------------------------------
    // Step 2: Program Descriptor 0 Registers
    // -------------------------------------------------------------------------
    // Descriptor Source Address (offset 0x0000_0020)
    addr = 32'h0000_0020;
    data = 32'h00000000;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

//write in an invalid offset
/* addr = 32'h0000_0025;
    data = 32'h00000004;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
*/


    // Descriptor Destination Address (offset 0x0000_0030)
    addr = 32'h0000_0030;
    data = 32'h1400;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Descriptor Number of Bytes (offset 0x0000_0040)
    addr = 32'h0000_0040;
    data = 32'h0000_0000;  // 32 bytes
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_len");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Descriptor Configuration (offset 0x0000_0050)
    addr = 32'h0000_0050;
    data = 32'h0000_0004;  // Enable descriptor in INCR mode
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

// -------------------------------------------------------------------------
    // Step 1: Program DMA Control Register to start transfer (go=1, abort=0, max_burst=8)
    // -------------------------------------------------------------------------
    addr = 32'h0000_0000;
    data = 32'h0000_0021; // Control: go=1, abort=0, max_burst=8
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);


    `uvm_info(get_name(), "Descriptor and Control Registers programmed, transfer initiated", UVM_LOW);

    // -------------------------------------------------------------------------
    // Step 3: Wait for the error to be injected (simulate error during transfer)
    // -------------------------------------------------------------------------
    // Allow enough delay for the DMA to start processing the transfer and for
    // the error injection mechanism in the slave to trigger.
    #100ns;

    // -------------------------------------------------------------------------
    // Step 4: Read Back DMA Error Registers to verify error capture
    // -------------------------------------------------------------------------
    // Read DMA Error Address Register (offset 0x0000_0010)
    addr = 32'h0000_0010;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq_err_addr");
    read_seq.READ = 1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("DMA Error Address Register (0x%0h): 0x%0h", addr, read_seq.item.dma_s_rdata), UVM_MEDIUM);

    // Read DMA Error Statistics Register (offset 0x0000_0018)
    addr = 32'h0000_0018;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq_err_stats");
    read_seq.READ = 1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("DMA Error Statistics Register (0x%0h): 0x%0h", addr, read_seq.item.dma_s_rdata), UVM_MEDIUM);

    // Optionally, read DMA Status Register (offset 0x0000_0008) to check that transfer has halted.
    addr = 32'h0000_0008;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq_status");
    read_seq.READ = 1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("DMA Status Register (0x%0h): 0x%0h", addr, read_seq.item.dma_s_rdata), UVM_MEDIUM);

    `uvm_info(get_name(), "Error Injection Sequence Completed", UVM_LOW);
  endtask
endclass
