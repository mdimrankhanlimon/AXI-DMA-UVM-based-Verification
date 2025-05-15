class axi4lite_m_multi_desc_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_multi_desc_seq)

  axi4lite_m_write_seq write_seq;
  axi4lite_m_read_seq  read_seq;

  // Constructor
  function new(string name = "axi4lite_m_multi_desc_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting Multiple Descriptor Configuration Sequence", UVM_LOW);

    // Set common parameters: non-secure, full word strobe.
    prot = 3'b010;
    strb = 4'b1111;
    WRITE = 1;
    READ  = 0;

   
    // -------------------------------------------------------------------------
    // Step 2: Program Descriptor 0 Registers (Descriptor index 0)
    // -------------------------------------------------------------------------
    // Source Address (offset 0x0000_0020)
    addr = 32'h0000_0020;
    data = 32'h10000000;       // Descriptor 0 source address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src0");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Destination Address (offset 0x0000_0030)
    addr = 32'h0000_0030;
    data = 32'h20000000;       // Descriptor 0 destination address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst0");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Number of Bytes (offset 0x0000_0040)
    addr = 32'h0000_0040;
    data = 32'h0000_0100;       // 256 bytes for descriptor 0
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_len0");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Descriptor Configuration (offset 0x0000_0050)
    addr = 32'h0000_0050;
    data = 32'h0000_0004;       // Enable descriptor (desc_cfg enable bit = 1, INCR mode)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg0");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -------------------------------------------------------------------------
    // Step 3: Program Descriptor 1 Registers (Descriptor index 1)
    // -------------------------------------------------------------------------
    // Source Address for Descriptor 1 (offset 0x0000_0028)
    addr = 32'h0000_0028;
    data = 32'h10001000;       // Descriptor 1 source address (different)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src1");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Destination Address for Descriptor 1 (offset 0x0000_0038)
    addr = 32'h0000_0038;
    data = 32'h20001000;       // Descriptor 1 destination address (different)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst1");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Number of Bytes for Descriptor 1 (offset 0x0000_0048)
    addr = 32'h0000_0048;
    data = 32'h0000_0200;       // 512 bytes for descriptor 1
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_len1");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Descriptor Configuration for Descriptor 1 (offset 0x0000_0058)
    addr = 32'h0000_0058;
    data = 32'h0000_0004;       // Enable descriptor 1 in INCR mode
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg1");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
 // -------------------------------------------------------------------------
    // Step 1: Program the DMA Control Register
    // -------------------------------------------------------------------------
    addr = 32'h0000_0000;       // DMA Control Register offset
    data = 32'h0000_0021;       // 0x21: go=1, abort=0, max_burst=8
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    `uvm_info(get_name(), "All Descriptors Configured. DMA Transfer should now commence.", UVM_LOW);

    // -------------------------------------------------------------------------
    // Optionally, you adding a delay here to allow the DMA to process both descriptors
    // and then read back the DMA status register to verify that dma_done_o is asserted.
    // -------------------------------------------------------------------------
    #100ns;
    addr = 32'h0000_0008;  // Assume DMA status register is at this offset.
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq_status");
    read_seq.READ = 1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer, this);
    `uvm_info(get_name(), $sformatf("DMA Status Register (0x%0h) read: 0x%0h", addr, read_seq.item.dma_s_rdata), UVM_MEDIUM);

    `uvm_info(get_name(), "Multiple Descriptor Configuration Sequence Completed", UVM_LOW);
  endtask
endclass

