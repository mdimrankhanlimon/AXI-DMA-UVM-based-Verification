class axi4lite_m_unaligned_src_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_unaligned_src_seq)

  axi4lite_m_write_seq write_seq;
  axi4lite_m_reset_seq reset_seq;

  // Constructor
  function new(string name = "axi4lite_m_unaligned_src_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting Unaligned Source Transfer Sequence", UVM_LOW);

    // Set common values: non-secure protection and full strobes
    prot  = 3'b010;
    strb  = 4'b1111;
    WRITE = 1;
    READ  = 0;

    // reset sequence
    reset_seq = axi4lite_m_reset_seq::type_id::create("reset_seq");
    reset_seq.start(m_sequencer,this);


    // -----------------------------------------------
    // 1. Write Descriptor Source Address (unaligned) at offset 0x0020
    addr = 32'h0000_0020;
    data = 32'h00000002;  // Unaligned source address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    // For register writes, we use full strobes. The driver/DUT is expected to handle the unalignment.
    write_seq.strb  = strb;  
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // 2. Write Descriptor Destination Address at offset 0x0030
    addr = 32'h0000_0030;
    data = 32'h000000C02;  // Aligned destination address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // 3. Write Descriptor Number of Bytes at offset 0x0040
    addr = 32'h0000_0040;
    data = 32'h0000_0012;  // 256 bytes
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_len");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // 4. Write Descriptor Configuration at offset 0x0050
    addr = 32'h0000_0050;
    data = 32'h0000_0004;  // Descriptor configuration (e.g., INCR mode and descriptor enable)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // 5. Final: Write the DMA Control Register at offset 0x0000_0000
    // This triggers the DMA transfer with go = 1, abort = 0, and max_burst = 8.
    addr = 32'h0000_0000;
    data = 32'h0000_0011;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    `uvm_info(get_name(), "Unaligned Source Transfer Sequence Completed. DMA transfer initiated.", UVM_LOW);
  endtask

endclass

