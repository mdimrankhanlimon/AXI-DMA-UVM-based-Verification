class axi4lite_m_multiple_burst_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_multiple_burst_seq)

  axi4lite_m_write_seq write_seq;
  axi4lite_m_read_seq  read_seq;

  // Constructor
  function new(string name = "axi4lite_m_multiple_burst_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting Transfer Configuration for 256 Bytes, max_burst=8", UVM_LOW);

    // Set non-secure protection (AXI_NONSECURE) and full-word strobe
    prot = 3'b010;
    strb = 4'b1111;
    WRITE = 1;
    READ  = 0;

    //-------------------------------------------------------------------------
    // Write Phase: Configure DMA for a 256-byte transfer using a single descriptor.
    //-------------------------------------------------------------------------
   
    // 2. Write Descriptor Source Address Register at offset 0x0000_0020
    addr = 32'h0000_0020;       // Descriptor Source Address offset
    data = 32'h1000_0000;       // Example source address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("Wrote 0x%0h to Descriptor Source Register (0x%0h)", data, addr), UVM_MEDIUM);

    // 3. Write Descriptor Destination Address Register at offset 0x0000_0030
    addr = 32'h0000_0030;       // Descriptor Destination Address offset
    data = 32'h2000_0000;       // Example destination address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("Wrote 0x%0h to Descriptor Destination Register (0x%0h)", data, addr), UVM_MEDIUM);

    // 4. Write Descriptor Number of Bytes Register at offset 0x0000_0040
    addr = 32'h0000_0040;       // Descriptor Number of Bytes offset
    data = 32'h0000_0100;       // 256 bytes (0x100)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_len");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("Wrote 0x%0h to Descriptor Num Bytes Register (0x%0h)", data, addr), UVM_MEDIUM);

    // 5. Write Descriptor Configuration Register at offset 0x0000_0050
    addr = 32'h0000_0050;       // Descriptor Configuration offset
    data = 32'h0000_0004;       // 0x4 -> normal mode (INCR) and enable descriptor
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("Wrote 0x%0h to Descriptor Config Register (0x%0h)", data, addr), UVM_MEDIUM);
 
    // 1. Write DMA Control Register at offset 0x0000_0000
    //    Set go=1, abort=0, and max_burst=8.
    addr = 32'h0000_0000;       // Control Register offset
    data = 32'h0000_0021;       // 0x21 -> go=1, abort=0, max_burst=8 (encoded)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("Wrote 0x%0h to DMA Control Register (0x%0h)", data, addr), UVM_MEDIUM);

    //-------------------------------------------------------------------------
    // Optional: Delay to allow the DMA to process the configuration before reading back.
    //-------------------------------------------------------------------------
    #20ns;

    //-------------------------------------------------------------------------
    // Read Phase: Optionally, read back one or more registers to verify the configuration.
    // Here, we read back the DMA Control Register as an example.
    //-------------------------------------------------------------------------
    addr = 32'h0000_0000;  // DMA Control Register offset
    READ = 1;
    WRITE = 0;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq_ctrl");
    read_seq.READ = 1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("Read DMA Control Register (0x%0h): 0x%0h", addr, read_seq.item.dma_s_rdata), UVM_MEDIUM);

    `uvm_info(get_name(), "Transfer Configuration Sequence Completed", UVM_LOW);
  endtask

endclass

