////3RD MODIFICATION
class axi4lite_m_csr_wr_rd_custom_seq extends axi4lite_m_base_seq;
  `uvm_object_utils(axi4lite_m_csr_wr_rd_custom_seq)

  //------------------------------------------------------------------------
  // Plusarg knobs & defaults
  //------------------------------------------------------------------------
  string num_des        = "single"; // "single" or "multi"
  string src_addr_type  = "AL";     // "AL" or "UNAL"
  string dest_addr_type = "AL";     // "AL" or "UNAL"

  string burst_mode     = "II";     // II=inc/inc, FF=fixed/fixed, FI=fixed/inc, IF=inc/fixed
  string burst_mode2    = "";

  // descriptor-0 knobs & defaults
  string data_src        = "0x0";
  string data_dest       = "0x1400";
  string data_num_bytes  = "0x24";
  string data_des_config = "0x4";
  string data_ctrl       = "0x21";

  // descriptor-1 knobs & defaults (if multi)
  string data_src2        = "0x4";
  string data_dest2       = "0x1400";
  string data_num_bytes2  = "0x48";
  string data_des_config2 = "0x4";

  // flags: did user really pass those knobs?
  bit got_data_src, got_data_dest;
  bit got_data_src2,got_data_dest2;

  // UVC sequence handles
  axi4lite_m_write_seq write_seq;
  axi4lite_m_read_seq  read_seq;
  axi4lite_m_reset_seq reset_seq;

  //------------------------------------------------------------------------
  // CSR Offsets
  //------------------------------------------------------------------------
  localparam int unsigned DMA_CONTROL_OFFSET     = 'h00;
  localparam int unsigned DMA_STATUS_OFFSET      = 'h08;
  localparam int unsigned DMA_ERROR_ADDR_OFFSET  = 'h10;
  localparam int unsigned DMA_ERROR_STATS_OFFSET = 'h18;

  localparam int unsigned DESC0_SRC_OFFSET       = 'h20;
  localparam int unsigned DESC0_DST_OFFSET       = 'h30;
  localparam int unsigned DESC0_NUM_BYTES_OFFSET = 'h40;
  localparam int unsigned DESC0_CFG_OFFSET       = 'h50;

  localparam int unsigned DESC1_SRC_OFFSET       = 'h28;
  localparam int unsigned DESC1_DST_OFFSET       = 'h38;
  localparam int unsigned DESC1_NUM_BYTES_OFFSET = 'h48;
  localparam int unsigned DESC1_CFG_OFFSET       = 'h58;

  //------------------------------------------------------------------------
  function new(string name = "axi4lite_m_csr_wr_rd_custom_seq");
    super.new(name);
  endfunction

  //------------------------------------------------------------------------
  // simple hex/dec ? int
  function int unsigned str_to_int(string s);
    int unsigned v;
    if ($sscanf(s, "0x%x", v))   return v;
    else if ($sscanf(s, "%d", v)) return v;
    else                          return 0;
  endfunction

  //------------------------------------------------------------------------
  // random addr in [min..max-size], optionally word-aligned
  function int unsigned gen_addr(
    int unsigned min,
    int unsigned max,
    int unsigned size,
    bit          aligned
  );
    int unsigned lo = min;
    int unsigned hi = max - size;
 int unsigned v;
    if (aligned) begin
      int unsigned steps = (hi - lo) / 4;
      return lo + ( $urandom_range(0, steps) * 4 );
    end else
		 begin
    	// pick any random then nudge off a 4-byte boundary if needed
    		v = $urandom_range(lo, hi);
    		if ((v % 4) == 0)   
      			v = (v == hi) ? v - 1: v + 1;
    		return v;
 		 end
    
  endfunction

  //------------------------------------------------------------------------
  // range + alignment check
  function void check_addr_and_alignment(
    int unsigned v,
    string        which,    // "SRC" or "DEST"
    bit           aligned
  );
    if (which == "SRC") begin
      if (v > 10240)
        `uvm_warning(get_type_name(), $sformatf("SRC out of [0..3071]: %0d", v));
    end else begin
      if (v < 0 || v > 10240)
        `uvm_warning(get_type_name(), $sformatf("DEST out of [3072..5120]: %0d", v));
    end
    if (aligned && (v % 4) != 0)
      `uvm_warning(get_type_name(), $sformatf("%s not word-aligned: %0d", which, v));
  endfunction

  //------------------------------------------------------------------------
  // capture plusargs & record what was passed
  function void capture_plusargs();
    bit got;

    if (!$value$plusargs("NUM_DES=%s", num_des))   num_des = "single";
    $value$plusargs("SRC_ADDR_TYPE=%s",  src_addr_type);   // default AL if not passed
    $value$plusargs("DEST_ADDR_TYPE=%s", dest_addr_type);  // default AL if not passed

    if (!$value$plusargs("BURST_MODE=%s", burst_mode))     burst_mode = "II";
    burst_mode2 = burst_mode;
    got = $value$plusargs("DATA_DES_CONFIG=%s", data_des_config);
    if (!got) begin
      case (burst_mode)
        "II": data_des_config = "0x4";
        "FF": data_des_config = "0x7";
        "FI": data_des_config = "0x6";
        "IF": data_des_config = "0x5";
        default: data_des_config = "0x4";
      endcase
    end

    $value$plusargs("DATA_NUM_BYTES=%s", data_num_bytes);
    $value$plusargs("DATA_CTRL=%s",       data_ctrl);

    got_data_src  = $value$plusargs("DATA_SRC=%s",  data_src);
    got_data_dest = $value$plusargs("DATA_DEST=%s", data_dest);

    if (num_des == "multi") begin
      $value$plusargs("BURST_MODE2=%s",      burst_mode2);
      got = $value$plusargs("DATA_DES_CONFIG2=%s", data_des_config2);
      if (!got) begin
        case (burst_mode2)
          "II": data_des_config2 = "0x4";
          "FF": data_des_config2 = "0x7";
          "FI": data_des_config2 = "0x6";
          "IF": data_des_config2 = "0x5";
          default: data_des_config2 = "0x4";
        endcase
      end
      $value$plusargs("DATA_NUM_BYTES2=%s", data_num_bytes2);
      got_data_src2  = $value$plusargs("DATA_SRC2=%s",  data_src2);
      got_data_dest2 = $value$plusargs("DATA_DEST2=%s", data_dest2);
    end
  endfunction

  //------------------------------------------------------------------------
  virtual task body();
    // locals first
    int unsigned nb0, cfg0, src0, dst0;
    int unsigned nb1, cfg1, src1, dst1;

    prot = 3'b010;
    strb = 4'b1111;

    capture_plusargs();
    `uvm_info(get_name(),
      $sformatf("CSR seq start: NUM_DES=%s  SRC_AT=%s  DEST_AT=%s  BURST=%s",
                num_des, src_addr_type, dest_addr_type, burst_mode),
      UVM_LOW);

    // 1) reset
    reset_seq = axi4lite_m_reset_seq::type_id::create("rst");
    reset_seq.start(m_sequencer, this);
    #20ns;

    // 2) compute descriptor-0
    nb0  = str_to_int(data_num_bytes);
    cfg0 = str_to_int(data_des_config);

    // 2a) SRC
    if (got_data_src) begin
      src0 = str_to_int(data_src);
    end else begin
      // pick a random block for SRC
      // default block for SRC: full low half [0..3071]
      src0 = gen_addr(0, 10240, nb0, src_addr_type=="AL");
    end

    // 2b) DST ? always from the opposite half
    if (got_data_dest) begin
      dst0 = str_to_int(data_dest);
    end else begin
      if (src0 <= 5119) begin
        // SRC in low half ? DEST in high half
        dst0 = gen_addr(5120, 10240, nb0, dest_addr_type=="AL");
      end else begin
        // SRC wound up in high half ? DEST in low half
        dst0 = gen_addr(0, 5119, nb0, dest_addr_type=="AL");
      end
    end

    check_addr_and_alignment(src0, "SRC",  src_addr_type=="AL");
    check_addr_and_alignment(dst0, "DEST", dest_addr_type=="AL");

    // 3) write descriptor-0
    addr = DESC0_SRC_OFFSET;       data = src0;
    write_seq = axi4lite_m_write_seq::type_id::create("wr0_src");
    write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
    write_seq.prot=prot; write_seq.strb=strb;
    write_seq.start(m_sequencer,this);

    addr = DESC0_DST_OFFSET;       data = dst0;
    write_seq = axi4lite_m_write_seq::type_id::create("wr0_dst");
    write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
    write_seq.prot=prot; write_seq.strb=strb;
    write_seq.start(m_sequencer,this);

    addr = DESC0_NUM_BYTES_OFFSET; data = nb0;
    write_seq = axi4lite_m_write_seq::type_id::create("wr0_len");
    write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
    write_seq.prot=prot; write_seq.strb=strb;
    write_seq.start(m_sequencer,this);

    addr = DESC0_CFG_OFFSET;       data = cfg0;
    write_seq = axi4lite_m_write_seq::type_id::create("wr0_cfg");
    write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
    write_seq.prot=prot; write_seq.strb=strb;
    write_seq.start(m_sequencer,this);

    // 4) if multi, descriptor-1 exactly the same �opposite-block� logic
    if (num_des == "multi") begin
      nb1  = str_to_int(data_num_bytes2);
      cfg1 = str_to_int(data_des_config2);

      if (got_data_src2) begin
        src1 = str_to_int(data_src2);
      end else begin
        src1 = gen_addr(0, 10240, nb1, src_addr_type=="AL");
      end

      if (got_data_dest2) begin
        dst1 = str_to_int(data_dest2);
      end else begin
        if (src1 <= 5119)
          dst1 = gen_addr(5120, 10240, nb1, dest_addr_type=="AL");
        else
          dst1 = gen_addr(0, 5119, nb1, dest_addr_type=="AL");
      end

      check_addr_and_alignment(src1, "SRC",  src_addr_type=="AL");
      check_addr_and_alignment(dst1, "DEST", dest_addr_type=="AL");

      addr = DESC1_SRC_OFFSET;       data = src1;
      write_seq = axi4lite_m_write_seq::type_id::create("wr1_src");
      write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
      write_seq.prot=prot; write_seq.strb=strb;
      write_seq.start(m_sequencer,this);

      addr = DESC1_DST_OFFSET;       data = dst1;
      write_seq = axi4lite_m_write_seq::type_id::create("wr1_dst");
      write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
      write_seq.prot=prot; write_seq.strb=strb;
      write_seq.start(m_sequencer,this);

      addr = DESC1_NUM_BYTES_OFFSET; data = nb1;
      write_seq = axi4lite_m_write_seq::type_id::create("wr1_len");
      write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
      write_seq.prot=prot; write_seq.strb=strb;
      write_seq.start(m_sequencer,this);

      addr = DESC1_CFG_OFFSET;       data = cfg1;
      write_seq = axi4lite_m_write_seq::type_id::create("wr1_cfg");
      write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
      write_seq.prot=prot; write_seq.strb=strb;
      write_seq.start(m_sequencer,this);
    end

    // 5) kick off DMA (single control reg)
    addr = DMA_CONTROL_OFFSET; data = str_to_int(data_ctrl);
    write_seq = axi4lite_m_write_seq::type_id::create("wr_ctrl");
    write_seq.WRITE=1; write_seq.addr=addr; write_seq.data=data;
    write_seq.prot=prot; write_seq.strb=strb;
    write_seq.start(m_sequencer,this);

    #100ns;

    // 6) read back status & error CSRs
    addr = DMA_STATUS_OFFSET;
    read_seq = axi4lite_m_read_seq::type_id::create("rd_status");
    read_seq.READ=1; read_seq.addr=addr; read_seq.prot=prot;
    read_seq.start(m_sequencer,this);

    addr = DMA_ERROR_ADDR_OFFSET;
    read_seq = axi4lite_m_read_seq::type_id::create("rd_err_addr");
    read_seq.READ=1; read_seq.addr=addr; read_seq.prot=prot;
    read_seq.start(m_sequencer,this);

    addr = DMA_ERROR_STATS_OFFSET;
    read_seq = axi4lite_m_read_seq::type_id::create("rd_err_stats");
    read_seq.READ=1; read_seq.addr=addr; read_seq.prot=prot;
    read_seq.start(m_sequencer,this);

    `uvm_info(get_name(), "CSR sequence completed", UVM_LOW);
  endtask


 // constraint non_zero_addr {
 // 
 // 	addr != 0;
 // 
 // }


endclass


