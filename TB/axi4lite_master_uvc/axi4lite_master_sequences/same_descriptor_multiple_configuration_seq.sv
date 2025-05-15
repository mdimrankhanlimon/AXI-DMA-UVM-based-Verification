class same_descriptor_multiple_configuration_sequence extends axi4lite_m_base_seq;
  `uvm_object_utils(same_descriptor_multiple_configuration_sequence)

  axi4lite_m_write_seq write_seq;
  axi4lite_m_reset_seq reset_seq;
  axi4lite_m_read_seq read_seq;
	bit done;

  // Constructor
  function new(string name = "same_descriptor_multiple_configuration_sequence");
    super.new(name);
  endfunction
 task read_done_bit(output bit done);
    axi4lite_m_read_seq rd;

    // build a one-shot status read
    rd = axi4lite_m_read_seq::type_id::create("poll_done");
    rd.READ = 1;
    rd.addr = 32'h08;
    rd.prot = 3'b010;
    rd.start(m_sequencer, this);

    // after it completes, grab the LSB of the returned rdata
    done = rd.item.dma_s_rdata[16];
  endtask
  // wait for DONE to go high, then return low again
  task wait_for_done();
    bit done;
    // 1) wait until done==1
    do begin
      read_done_bit(done);
    end while (!done);
    `uvm_info(get_name(), "DMA done ? 1 detected", UVM_HIGH);

    // 2) then wait until done==0 (i.e. cleared)
    do begin
      read_done_bit(done);
    end while (done);
    `uvm_info(get_name(), "DMA done ? 0 detected, ready for next config", UVM_HIGH);
  endtask

  // Body task: Write CSR registers according to configuration spec
  virtual task body();
    `uvm_info(get_name(), "Starting CSR Write Sequence", UVM_LOW);
	repeat (5) begin
    // reset sequence
    reset_seq = axi4lite_m_reset_seq::type_id::create("reset_seq");
    reset_seq.start(m_sequencer,this);

    // Define protection and common signals (inherited from base sequence)
    prot = 3'b010;   // Typically non-secure (AXI_NONSECURE)
    strb = 4'b1111;  // Full byte write enable
    WRITE = 1;

      
    // -----------------------------------------------
    // Write DMA Descriptor Source Address for descriptor 0 (offset 0x20)
    addr = 32'h0000_0020;  // DMA Descriptor Source Address Offset
    data = 32'h8;  // Example source address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // Write DMA Descriptor Destination Address for descriptor 0 (offset 0x30)
    addr = 32'h0000_0030;  // DMA Descriptor Destination Address Offset
    data = 32'h1400;  // Example destination address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // Write DMA Descriptor Number of Bytes for descriptor 0 (offset 0x40)
    addr = 32'h0000_0040;  // DMA Descriptor Number of Bytes Offset
    data = 32'h0000_0024;  // 32 bytes (0x020) 64 (0*040)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;

    // -----------------------------------------------
    // Write DMA Descriptor Configuration for descriptor 0 (offset 0x50)
    addr = 32'h0000_0050;  // DMA Descriptor Configuration Offset
    data = 32'h0000_0004;  // Example configuration: e.g., write_mode=0, read_mode=0, enable=1; 004->incr, 007 -> fixed
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // Write DMA Control Register at offset 0x00
    // dma_control: go = 1, abort = 0, max_burst = 8.
    // If max_burst is encoded in bits [9:2], then (8 << 2) = 32 (0x20)
    // And adding go (bit 0 = 1), value becomes 0x21.
	
	  addr = 32'h0000_0000;  // DMA Control Register Offset
    data = 32'h21;  // Configuration value: go=1, abort=0, max_burst=8
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);
	

//	wait_for_done();
	
    addr = 32'h0000_0000;  // DMA Control Register Offset
    data = 32'h20;  // Configuration value: go=1, abort=0, max_burst=8
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

   

	addr = 32'h0000_0020;  // DMA Descriptor Source Address Offset
    data = 32'h4;  // Example source address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // Write DMA Descriptor Destination Address for descriptor 0 (offset 0x30)
    addr = 32'h0000_0030;  // DMA Descriptor Destination Address Offset
    data = 32'h1404;  // Example destination address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // Write DMA Descriptor Number of Bytes for descriptor 0 (offset 0x40)
    addr = 32'h0000_0040;  // DMA Descriptor Number of Bytes Offset
    data = 32'h0000_0048;  // 32 bytes (0x020) 64 (0*040)
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    // -----------------------------------------------
    // Write DMA Descriptor Configuration for descriptor 0 (offset 0x50)
    addr = 32'h0000_0050;  // DMA Descriptor Configuration Offset
    data = 32'h0000_0004;  // Example configuration: e.g., write_mode=0, read_mode=0, enable=1; 004->incr, 007 -> fixed
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

 // -----------------------------------------------
    // Write DMA Descriptor Source Address for descriptor 0 (offset 0x20)
    addr = 32'h0000_0000;  // DMA Descriptor Source Address Offset
    data = 32'h21;  // Example source address
    write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
    write_seq.WRITE = WRITE;
    write_seq.addr  = addr;
    write_seq.data  = data;
    write_seq.prot  = prot;
    write_seq.strb  = strb;
    write_seq.start(m_sequencer, this);

    `uvm_info(get_name(), "CSR Write Sequence Completed", UVM_LOW);

    // Read DMA Control Register at offset 0x00
    addr = 32'h0000_0000;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
    read_seq.READ=1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer,this);

    addr = 32'h0000_0008;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
    read_seq.READ=1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer,this);

    addr = 32'h0000_0010;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
    read_seq.READ=1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer,this);

    addr = 32'h0000_0018;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
    read_seq.READ=1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer,this);

    // Read DMA Descriptor Source Address at offset 0x20
    addr = 32'h0000_0020;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
    read_seq.READ=1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer,this);

    // Read DMA Descriptor Destination Address at offset 0x30
    addr = 32'h0000_0030;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
    read_seq.READ=1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer,this);

    // Read DMA Descriptor Number of Bytes at offset 0x40
    addr = 32'h0000_0040;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
    read_seq.READ=1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer,this);

    // Read DMA Descriptor Configuration at offset 0x50
    addr = 32'h0000_0050;
    read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
    read_seq.READ=1;
    read_seq.addr = addr;
    read_seq.prot = prot;
    read_seq.start(m_sequencer,this);

    `uvm_info(get_name(), "CSR Write-Read Sequence Completed", UVM_LOW);
    #300;
  end
  endtask
endclass

