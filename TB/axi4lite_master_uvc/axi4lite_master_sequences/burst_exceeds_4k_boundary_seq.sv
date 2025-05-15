class axi4lite_m_boundary_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_boundary_seq)

  axi4lite_m_write_seq write_seq;
  axi4lite_m_read_seq  read_seq;

  // Constructor
  function new(string name = "axi4lite_m_boundary_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting 4KB Boundary Test Sequence", UVM_LOW);

    // Set common signals: non-secure protection, full-word write strobe.
    prot = 3'b010;
    strb = 4'b1111;
    WRITE = 1;
    READ  = 0;

   
    // Write Descriptor Source Address at offset 0x0000_0020
    // Source address near 4KB boundary
    addr = 32'h0000_0020;
    data = 32'h00000010;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Write Descriptor Destination Address at offset 0x0000_0030
    addr = 32'h0000_0030;
    data = 32'hFFC;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;  
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Write Descriptor Number of Bytes at offset 0x0000_0040
    // 8192 bytes = 0x2000
    addr = 32'h0000_0040;
    data = 32'h0000_0010;   // 
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_len");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Write Descriptor Configuration at offset 0x0000_0050
    // 0x4: INCR mode and descriptor enabled
    addr = 32'h0000_0050;
    data = 32'h0000_0004;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    `uvm_info(get_name(), "Descriptor and Control Registers programmed", UVM_LOW);
 // ---------------------------------------------------------
    // Step 1: Program the Descriptor and Control Registers
    // ---------------------------------------------------------
    // Write DMA Control Register at offset 0x0000_0000
    // 0x21: go=1, abort=0, max_burst=8
    addr = 32'h0000_0000;
    data = 32'h0000_0011;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // ---------------------------------------------------------
    // Step 2: Wait for the DMA Transfer to Process
    // ---------------------------------------------------------
    // Delay long enough for the transfer to start and complete multiple bursts.
    #200ns;

    // ---------------------------------------------------------
    // Step 3: Read Back DMA Status to Verify Completion
    // ---------------------------------------------------------
    // Read DMA Status Register at offset 0x0000_0008
    addr = 32'h0000_0008;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq_status");
    read_seq.READ = 1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("DMA Status Register (0x%0h) read: 0x%0h", addr, read_seq.item.dma_s_rdata), UVM_MEDIUM);

    `uvm_info(get_name(), "4KB Boundary Test Sequence Completed", UVM_LOW);
  endtask

endclass

