class axi4lite_m_csr_control_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_control_write_seq)

  // Data to write
  int unsigned ctrl_value;

  function new(string name = "axi4lite_m_csr_control_write_seq", int unsigned value = 0);
    super.new(name);
    ctrl_value = value;
  endfunction

  virtual task body();
    // configure common fields
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h00;           // DMA_CONTROL_OFFSET
    data = ctrl_value;
    // invoke base write
    super.body();
  endtask
endclass

// DMA Control Register Read Sequence
class axi4lite_m_csr_control_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_control_read_seq)

  function new(string name = "axi4lite_m_csr_control_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h00;           // DMA_CONTROL_OFFSET
    super.body();
  endtask
endclass

// DMA Status Register Read Sequence
class axi4lite_m_csr_status_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_status_read_seq)

  function new(string name = "axi4lite_m_csr_status_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h08;           // DMA_STATUS_OFFSET
    super.body();
  endtask
endclass

// DMA Error Address Register Read Sequence
class axi4lite_m_csr_error_addr_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_error_addr_read_seq)

  function new(string name = "axi4lite_m_csr_error_addr_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h10;           // DMA_ERROR_ADDR_OFFSET
    super.body();
  endtask
endclass

// DMA Error Stats Register Read Sequence
class axi4lite_m_csr_error_stats_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_error_stats_read_seq)

  function new(string name = "axi4lite_m_csr_error_stats_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h18;           // DMA_ERROR_STATS_OFFSET
    super.body();
  endtask
endclass

// Descriptor 0 Source Address Write Sequence
class axi4lite_m_csr_desc0_src_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_desc0_src_write_seq)

  int unsigned src_value;

  function new(string name = "axi4lite_m_csr_desc0_src_write_seq", int unsigned value = 0);
    super.new(name);
    src_value = value;
  endfunction

  virtual task body();
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h20;          // DESC0_SRC_OFFSET
    data = src_value;
    super.body();
  endtask
endclass

// Descriptor 0 Source Address Read Sequence
class axi4lite_m_csr_desc0_src_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_desc0_src_read_seq)

  function new(string name = "axi4lite_m_csr_desc0_src_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h20;          // DESC0_SRC_OFFSET
    super.body();
  endtask
endclass

// Descriptor 0 Destination Address Write Sequence
class axi4lite_m_csr_desc0_dst_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_desc0_dst_write_seq)

  int unsigned dst_value;

  function new(string name = "axi4lite_m_csr_desc0_dst_write_seq", int unsigned value = 0);
    super.new(name);
    dst_value = value;
  endfunction

  virtual task body();
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h30;          // DESC0_DST_OFFSET
    data = dst_value;
    super.body();
  endtask
endclass

// Descriptor 0 Destination Address Read Sequence
class axi4lite_m_csr_desc0_dst_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_desc0_dst_read_seq)

  function new(string name = "axi4lite_m_csr_desc0_dst_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h30;          // DESC0_DST_OFFSET
    super.body();
  endtask
endclass

// Descriptor 0 Num Bytes Write Sequence
class axi4lite_m_csr_desc0_bytes_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_desc0_bytes_write_seq)

  int unsigned bytes_value;

  function new(string name = "axi4lite_m_csr_desc0_bytes_write_seq", int unsigned value = 0);
    super.new(name);
    bytes_value = value;
  endfunction

  virtual task body();
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h40;          // DESC0_NUM_BYTES_OFFSET
    data = bytes_value;
    super.body();
  endtask
endclass

// Descriptor 0 Num Bytes Read Sequence
class axi4lite_m_csr_desc0_bytes_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_desc0_bytes_read_seq)

  function new(string name = "axi4lite_m_csr_desc0_bytes_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h40;          // DESC0_NUM_BYTES_OFFSET
    super.body();
  endtask
endclass

// Descriptor 0 Config Write Sequence
class axi4lite_m_csr_desc0_cfg_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_desc0_cfg_write_seq)

  int unsigned cfg_value;

  function new(string name = "axi4lite_m_csr_desc0_cfg_write_seq", int unsigned value = 0);
    super.new(name);
    cfg_value = value;
  endfunction

  virtual task body();
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h50;          // DESC0_CFG_OFFSET
    data = cfg_value;
    super.body();
  endtask
endclass

// Descriptor 0 Config Read Sequence
class axi4lite_m_csr_desc0_cfg_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_desc0_cfg_read_seq)

  function new(string name = "axi4lite_m_csr_desc0_cfg_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h50;          // DESC0_CFG_OFFSET
    super.body();
  endtask
endclass

// Descriptor 1 variants are defined similarly using offsets 'h28, 'h38, 'h48, 'h58

//------------------------------------------------------------------------------
class axi4lite_m_csr_desc1_src_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_desc1_src_write_seq)

  int unsigned src_value;

  function new(string name = "axi4lite_m_csr_desc1_src_write_seq", int unsigned value = 0);
    super.new(name);
    src_value = value;
  endfunction

  virtual task body();
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h28;          // DESC1_SRC_OFFSET
    data = src_value;
    super.body();
  endtask
endclass

// Descriptor 1 Source Address Read Sequence
class axi4lite_m_csr_desc1_src_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_desc1_src_read_seq)

  function new(string name = "axi4lite_m_csr_desc1_src_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h28;          // DESC1_SRC_OFFSET
    super.body();
  endtask
endclass

// Descriptor 1 Destination Address Write Sequence
class axi4lite_m_csr_desc1_dst_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_desc1_dst_write_seq)

  int unsigned dst_value;

  function new(string name = "axi4lite_m_csr_desc1_dst_write_seq", int unsigned value = 0);
    super.new(name);
    dst_value = value;
  endfunction

  virtual task body();
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h38;          // DESC0_DST_OFFSET
    data = dst_value;
    super.body();
  endtask
endclass

// Descriptor 1 Destination Address Read Sequence
class axi4lite_m_csr_desc1_dst_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_desc1_dst_read_seq)

  function new(string name = "axi4lite_m_csr_desc1_dst_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h38;          // DESC1_DST_OFFSET
    super.body();
  endtask
endclass

// Descriptor 1 Num Bytes Write Sequence
class axi4lite_m_csr_desc1_bytes_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_desc1_bytes_write_seq)

  int unsigned bytes_value;

  function new(string name = "axi4lite_m_csr_desc1_bytes_write_seq", int unsigned value = 0);
    super.new(name);
    bytes_value = value;
  endfunction

  virtual task body();
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h48;          // DESC1_NUM_BYTES_OFFSET
    data = bytes_value;
    super.body();
  endtask
endclass

// Descriptor 1 Num Bytes Read Sequence
class axi4lite_m_csr_desc1_bytes_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_desc1_bytes_read_seq)

  function new(string name = "axi4lite_m_csr_desc1_bytes_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h48;          // DESC1_NUM_BYTES_OFFSET
    super.body();
  endtask
endclass

// Descriptor 1 Config Write Sequence
class axi4lite_m_csr_desc1_cfg_write_seq extends axi4lite_m_write_seq;
  `uvm_object_utils(axi4lite_m_csr_desc1_cfg_write_seq)

  int unsigned cfg_value;

  function new(string name = "axi4lite_m_csr_desc1_cfg_write_seq", int unsigned value = 0);
    super.new(name);
    cfg_value = value;
  endfunction

  virtual task body();
    prot = 3'b010;
    strb = 4'b1111;
    addr = 'h58;          // DESC1_CFG_OFFSET
    data = cfg_value;
    super.body();
  endtask
endclass

// Descriptor 1 Config Read Sequence
class axi4lite_m_csr_desc1_cfg_read_seq extends axi4lite_m_read_seq;
  `uvm_object_utils(axi4lite_m_csr_desc1_cfg_read_seq)

  function new(string name = "axi4lite_m_csr_desc1_cfg_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    prot = 3'b010;
    addr = 'h58;          // DESC1_CFG_OFFSET
    super.body();
  endtask
endclass
//------------------------------------------------------------------------------
