//------------------------------------------------------------------------------
// sample_sanity_sequence.sv
// Descriptor-0 write/read plus status/error reads
//------------------------------------------------------------------------------
class sample_sanity_sequence extends axi4lite_m_base_seq;
  `uvm_object_utils(sample_sanity_sequence)

   axi4lite_m_reset_seq reset_seq;

  // D0 write handles
  axi4lite_m_csr_desc0_src_write_seq   wr_src;
  axi4lite_m_csr_desc0_dst_write_seq   wr_dst;
  axi4lite_m_csr_desc0_bytes_write_seq wr_bytes;
  axi4lite_m_csr_desc0_cfg_write_seq   wr_cfg;
  axi4lite_m_csr_control_write_seq	   wr_cntrl;	

  // D0 read handles
  axi4lite_m_csr_control_read_seq      rd_cntrl;     
  axi4lite_m_csr_desc0_src_read_seq    rd_src;
  axi4lite_m_csr_desc0_dst_read_seq    rd_dst;
  axi4lite_m_csr_desc0_bytes_read_seq  rd_bytes;
  axi4lite_m_csr_desc0_cfg_read_seq    rd_cfg;

  // status/error read handles
  axi4lite_m_csr_status_read_seq       rd_status;
  axi4lite_m_csr_error_addr_read_seq   rd_err_addr;
  axi4lite_m_csr_error_stats_read_seq  rd_err_stats;

  function new(string name = "sample_sanity_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting sample_sanity_sequence", UVM_LOW)


 // reset sequence
    reset_seq = axi4lite_m_reset_seq::type_id::create("reset_seq");
    reset_seq.start(m_sequencer,this);




    // 1) Write descriptor-0 fields
    wr_src   = axi4lite_m_csr_desc0_src_write_seq::type_id::create("wr_src");
    wr_src.src_value   = 32'h0000_0000;
    wr_src.start(m_sequencer, this);

    wr_dst   = axi4lite_m_csr_desc0_dst_write_seq::type_id::create("wr_dst");
    wr_dst.dst_value   = 32'h0000_0C00;
    wr_dst.start(m_sequencer, this);

    wr_bytes = axi4lite_m_csr_desc0_bytes_write_seq::type_id::create("wr_bytes");
    wr_bytes.bytes_value = 32'h0000_0028;
    wr_bytes.start(m_sequencer, this);

    wr_cfg   = axi4lite_m_csr_desc0_cfg_write_seq::type_id::create("wr_cfg");
    wr_cfg.cfg_value   = 32'h0000_0004;
    wr_cfg.start(m_sequencer, this);

	wr_cntrl =axi4lite_m_csr_control_write_seq::type_id::create("wr_cntrl");
	wr_cntrl.ctrl_value=32'h0000_0011;
	wr_cntrl.start(m_sequencer,this);

	

	#70ns;
  wr_cntrl.ctrl_value=32'h0000_0010;
	wr_cntrl.start(m_sequencer,this);

  #10;
	wr_src.src_value   = 32'h0000_0C00;
  wr_src.start(m_sequencer, this);
	
	wr_dst.dst_value   = 32'h0000_0A00;
  wr_dst.start(m_sequencer, this);
    
	wr_bytes.bytes_value = 32'h0000_0028;
  wr_bytes.start(m_sequencer, this);

  wr_cfg.cfg_value   = 32'h0000_0004;
  wr_cfg.start(m_sequencer, this);

 	wr_cntrl.ctrl_value=32'h0000_0011;
	wr_cntrl.start(m_sequencer,this);

  #100ns;
  wr_cntrl.ctrl_value=32'h0000_0010;
	wr_cntrl.start(m_sequencer,this);
    // 2) Read back D0 registers
    #100ns;


	rd_cntrl=axi4lite_m_csr_control_read_seq::type_id::create("rd_cntrl");
	rd_cntrl.start(m_sequencer,this);

    rd_src   = axi4lite_m_csr_desc0_src_read_seq::type_id::create("rd_src");
    rd_src.start(m_sequencer, this);

    rd_dst   = axi4lite_m_csr_desc0_dst_read_seq::type_id::create("rd_dst");
    rd_dst.start(m_sequencer, this);

    rd_bytes = axi4lite_m_csr_desc0_bytes_read_seq::type_id::create("rd_bytes");
    rd_bytes.start(m_sequencer, this);

    rd_cfg   = axi4lite_m_csr_desc0_cfg_read_seq::type_id::create("rd_cfg");
    rd_cfg.start(m_sequencer, this);

    // 3) Read status and error registers
    #20ns;
    rd_status    = axi4lite_m_csr_status_read_seq::type_id::create("rd_status");
    rd_status.start(m_sequencer, this);

    rd_err_addr  = axi4lite_m_csr_error_addr_read_seq::type_id::create("rd_err_addr");
    rd_err_addr.start(m_sequencer, this);

    rd_err_stats = axi4lite_m_csr_error_stats_read_seq::type_id::create("rd_err_stats");
    rd_err_stats.start(m_sequencer, this);

    `uvm_info(get_name(), "sample_sanity_sequence completed", UVM_LOW)
  endtask
endclass



