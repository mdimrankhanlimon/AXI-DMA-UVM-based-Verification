class axi4lite_m_unaligned_destination_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_unaligned_destination_seq)

  axi4lite_m_write_seq write_seq;

  // Constructor
  function new(string name = "axi4lite_m_unaligned_destination_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting Unaligned Destination Transfer Sequence", UVM_LOW);

    // Set common values: non-secure protection and full strobes
    prot  = 3'b010;
    strb  = 4'b1111;
    WRITE = 1;
    READ  = 0;

    // -----------------------------------------------
    // 1. Write Descriptor Source Address (unaligned) at offset 0x0020
    addr = 32'h0000_0020;
    data = 32'h10000000;  // Unaligned source address
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
    data = 32'h20000002;  // Aligned destination address
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
    data = 32'h0000_0100;  // 256 bytes
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
    data = 32'h0000_0021;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    `uvm_info(get_name(), "Unaligned Destination Transfer Sequence Completed. DMA transfer initiated.", UVM_LOW);
  endtask

endclass

