class axi4lite_m_abort_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_abort_seq)

  axi4lite_m_write_seq write_seq;
 axi4lite_m_reset_seq reset_seq;

  // Constructor
  function new(string name = "axi4lite_m_abort_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting Abort Operation Mid-Transfer Sequence", UVM_LOW);

 // reset sequence
        reset_seq = axi4lite_m_reset_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer,this);

   
    //Configuration of a Long Transfer to Ensure Multiple Bursts
    // Write Descriptor Number of Bytes Register: Set transfer size to 256 bytes.
    addr = 32'h0000_0040;
    data = 32'h0000_024;  // 36 bytes
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_length");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = 3'b010;
    write_seq.strb  = 4'b1111;
    write_seq.start(m_sequencer, this);

    // configuration of DMA Descriptor Source Address Register at offset 0x0000_0020.
    addr = 32'h0000_0020;
    data = 32'h00000000;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = 3'b010;
    write_seq.strb  = 4'b1111;
    write_seq.start(m_sequencer, this);

    // Configuration of DMA Descriptor Destination Address Register at offset 0x0000_0030.
    addr = 32'h0000_0030;
    data = 32'h00000FA0;
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = 3'b010;
    write_seq.strb  = 4'b1111;
    write_seq.start(m_sequencer, this);

    // Write DMA Descriptor Configuration Register at offset 0x0000_0050.
    addr = 32'h0000_0050;
    data = 32'h0000_0004;  // INCR mode and enable descriptor.
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = 3'b010;
    write_seq.strb  = 4'b1111;
    write_seq.start(m_sequencer, this);

    // Write DMA Control Register at offset 0x0000_0000 to start transfer (go=1, abort=0, max_burst=8).
    addr = 32'h0000_0000;
    data = 32'h0000_0021;  // 0x21: go=1, abort=0, max_burst=8
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl_start");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = 3'b010;
    write_seq.strb  = 4'b1111;
    write_seq.start(m_sequencer, this);

    #50ns;  // Delay to let the transfer start (and multiple bursts to be in progress)

   
    //Asserting Abort by updating the DMA Control Register
  
    addr = 32'h0000_0000;
    data = 32'h0000_0022;  // 0x23: go=1, abort=1, max_burst=8 (Abort asserted)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq_abort");
    write_seq.WRITE = 1;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = 3'b010;
    write_seq.strb  = 4'b1111;
    write_seq.start(m_sequencer, this);

    `uvm_info(get_name(), "Abort Operation Mid-Transfer Sequence Completed", UVM_LOW);
  endtask

endclass







