class axi4lite_m_disabled_descriptor_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_disabled_descriptor_seq)

  axi4lite_m_write_seq write_seq;

  // Constructor
  function new(string name = "axi4lite_m_disabled_descriptor_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting Disabled Descriptor Sequence", UVM_LOW);

    // Define common signals: use non-secure protection and full-word strobe
    prot = 3'b010;
    strb = 4'b1111;
    WRITE = 1;

   
    // Step 1: Write Descriptor 0 Source Address
    addr = 32'h0000_0020;       // Descriptor Source Address offset
    data = 32'h1000_0000;       // Example source address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Step 2: Write Descriptor 0 Destination Address
    addr = 32'h0000_0030;       // Descriptor Destination Address offset
    data = 32'h2000_0000;       // Example destination address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Step 3: Write Descriptor 0 Number of Bytes Register
    addr = 32'h0000_0040;       // Descriptor Number of Bytes offset
    data = 32'h0000_0020;       // 32 bytes (0x020)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_len");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
    
	// Step 4: Write DMA Control Register to start transfer (go=1, abort=0)
    addr = 32'h0000_0000;       // DMA Control Register offset
    data = 32'h0000_0021;       // 0x21: go=1, abort=0, max_burst=8
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // Step 5: Write Descriptor 0 Configuration Register with Enable = 0
    addr = 32'h0000_0050;       // Descriptor Configuration offset
    data = 32'h0000_0000;       // Set enable bit to 0 (descriptor disabled)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    `uvm_info(get_name(), "Disabled Descriptor Sequence Completed. No transfer should occur.", UVM_LOW);
  endtask

endclass

