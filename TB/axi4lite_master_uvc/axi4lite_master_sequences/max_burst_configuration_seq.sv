class axi4lite_m_vary_max_burst_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_vary_max_burst_seq)

  axi4lite_m_write_seq write_seq;
  axi4lite_m_read_seq  read_seq;

    // Arrays for different max_burst settings and corresponding control values
    bit [7:0] max_burst_vals [0:2];
    bit [31:0] ctrl_vals      [0:2];

  function new(string name = "axi4lite_m_vary_max_burst_seq");
    super.new(name);
	 max_burst_vals[0] = 4;
    max_burst_vals[1] = 8;
    max_burst_vals[2] = 16;

    ctrl_vals[0] = 32'h00000011;
    ctrl_vals[1] = 32'h00000031;
    ctrl_vals[2] = 32'h00000071;
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting Varying Max Burst Sequence", UVM_LOW);

    // Define non-secure protection and full-word strobe
    prot = 3'b010;
    strb = 4'b1111;
    WRITE = 1;
    READ  = 0;

//    int i;
    // Loop over each max_burst configuration
    for (int i = 0; i < 3; i++) begin
     
      // 1. Write DMA Descriptor Source Address at offset 0x0000_0020
      addr = 32'h0000_0020;
      data = 32'h1000_0000; // Example: source address
     write_seq = axi4lite_m_write_seq::type_id::create($sformatf("write_seq_src_%0d", max_burst_vals[i]));
      //write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
      write_seq.WRITE = 1;
      write_seq.addr  = addr;
      write_seq.data  = data;
      write_seq.prot  = prot;
      write_seq.strb  = strb;
      write_seq.start(m_sequencer, this);

      // 2. Write DMA Descriptor Destination Address at offset 0x0000_0030
      addr = 32'h0000_0030;
      data = 32'h2000_0000; // Example: destination address
      write_seq = axi4lite_m_write_seq::type_id::create($sformatf("write_seq_dst_%0d", max_burst_vals[i]));
      //write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
      write_seq.WRITE = 1;
      write_seq.addr  = addr;
      write_seq.data  = data;
      write_seq.prot  = prot;
      write_seq.strb  = strb;
      write_seq.start(m_sequencer, this);

      // 3. Write DMA Descriptor Number of Bytes at offset 0x0000_0040
      addr = 32'h0000_0040;
      data = 32'h0000_0080; // 128 bytes
      write_seq = axi4lite_m_write_seq::type_id::create($sformatf("write_seq_len_%0d", max_burst_vals[i]));
      //write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
      write_seq.WRITE = 1;
      write_seq.addr  = addr;
      write_seq.data  = data;
      write_seq.prot  = prot;
      write_seq.strb  = strb;
      write_seq.start(m_sequencer, this);

      // 4. Write DMA Descriptor Configuration at offset 0x0000_0050
      addr = 32'h0000_0050;
      data = 32'h0000_0004; // Configuration: INCR mode, enable descriptor
      write_seq = axi4lite_m_write_seq::type_id::create($sformatf("write_seq_cfg_%0d", max_burst_vals[i]));
      //write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
      write_seq.WRITE = 1;
      write_seq.addr  = addr;
      write_seq.data  = data;
      write_seq.prot  = prot;
      write_seq.strb  = strb;
      write_seq.start(m_sequencer, this);

	`uvm_info(get_name(), $sformatf("Configuring DMA with max_burst = %0d", max_burst_vals[i]), UVM_LOW);

      // 5. Write DMA Control Register at offset 0x0000_0000
      addr = 32'h0000_0000;
      data = ctrl_vals[i];  // control: go=1, abort=0, with max_burst encoded
      write_seq = axi4lite_m_write_seq::type_id::create($sformatf("write_seq_ctrl_%0d", max_burst_vals[i]));
      //write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
      write_seq.WRITE = 1;
      write_seq.addr  = addr;
      write_seq.data  = data;
      write_seq.prot  = prot;
      write_seq.strb  = strb;
      write_seq.start(m_sequencer, this);

      `uvm_info(get_name(), $sformatf("DMA configured with max_burst = %0d", max_burst_vals[i]), UVM_LOW);
      // adding a small delay between different configurations.
      #10ns;
    end

    `uvm_info(get_name(), "Varying Max Burst Sequence Completed", UVM_LOW);
  endtask
endclass

