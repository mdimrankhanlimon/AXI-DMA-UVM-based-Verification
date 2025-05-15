`uvm_analysis_imp_decl(_axi4l_port)
`uvm_analysis_imp_decl(_axi4_port)

class dma_cvrg_sb extends uvm_component;
  `uvm_component_utils(dma_cvrg_sb)

  axi4lite_m_seq_item axi4l_trx;
  axi4_s_seq_item     axi4_trx;

  //TLM analysis ports
  uvm_analysis_imp_axi4l_port  #(axi4lite_m_seq_item, dma_cvrg_sb)  axi4l_trx_port;
  uvm_analysis_imp_axi4_port   #(axi4_s_seq_item, dma_cvrg_sb)  axi4_trx_port;

  // Local Parameters
  localparam  REGION_SIZE = (`END_ADDR - `START_ADDR ) / 3;
  localparam  MID_START   = `START_ADDR + REGION_SIZE;
  localparam  HIGH_START  =  MID_START + REGION_SIZE;

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
  
 
  covergroup dma_cg_lite;
		  
    
	dma_done_o_cp: coverpoint axi4l_trx.dma_done_o { 
		bins done     = {1};
		bins not_done = {0};
	}
    
	dma_error_o_cp: coverpoint axi4l_trx.dma_error_o { 
		bins error    = {1};
		bins no_error = {0};
	}
   
	dma_s_awaddr_cp: coverpoint axi4l_trx.dma_s_awaddr { 
			
		bins dma_control_addr      = {DMA_CONTROL_OFFSET};

  		bins desc0_src_addr        = {DESC0_SRC_OFFSET};
  		bins desc0_dst_addr        = {DESC0_DST_OFFSET};
  		bins desc0_num_bytes_addr  = {DESC0_NUM_BYTES_OFFSET};
  		bins desc0_cfg_addr        = {DESC0_CFG_OFFSET};	
			
		bins desc1_src_addr        = {DESC1_SRC_OFFSET};
  		bins desc1_dst_addr        = {DESC1_DST_OFFSET};
  		bins desc1_num_bytes_addr  = {DESC1_NUM_BYTES_OFFSET};
  		bins desc1_cfg_addr        = {DESC1_CFG_OFFSET};

		illegal_bins csr_illegal_wr_addr = default;
			
			}

	dma_control_go_cp: coverpoint axi4l_trx.dma_s_wdata[0]
    	iff (axi4l_trx.dma_s_awaddr == DMA_CONTROL_OFFSET) {
      		bins go     = {1};
      		bins not_go = {0};
    }
	
	dma_control_abort_cp: coverpoint axi4l_trx.dma_s_wdata[1]
    	iff (axi4l_trx.dma_s_awaddr == DMA_CONTROL_OFFSET) {
      		bins abort     = {1};
      		bins not_abort = {0};
    }

	dma_control_max_burst_cp: coverpoint axi4l_trx.dma_s_wdata[9:2]
    	iff (axi4l_trx.dma_s_awaddr == DMA_CONTROL_OFFSET) {
      		bins max_burst   = {255};
      		bins other_burst = {[0:254]};
    }

	dma_desc_src_addr_cp: coverpoint axi4l_trx.dma_s_wdata[13:0]
		iff (axi4l_trx.dma_s_awaddr == DESC0_SRC_OFFSET   || axi4l_trx.dma_s_awaddr == DESC1_SRC_OFFSET ) {
			bins low_bin  = {[0     : 3412]};
  			bins mid_bin  = {[3413  : 6825]};
  			bins high_bin = {[6826  : 10239]};
		
		}

	dma_desc_dst_addr_cp: coverpoint axi4l_trx.dma_s_wdata[13:0]
		iff (axi4l_trx.dma_s_awaddr == DESC0_DST_OFFSET   || axi4l_trx.dma_s_awaddr == DESC1_DST_OFFSET ) {
			bins low_bin  = {[0     : 3412]};
  			bins mid_bin  = {[3413  : 6825]};
  			bins high_bin = {[6826  : 10239]};
		
		}

	dma_desc_num_bytes_cp: coverpoint axi4l_trx.dma_s_wdata[12:0]
		iff (axi4l_trx.dma_s_awaddr == DESC0_NUM_BYTES_OFFSET   || axi4l_trx.dma_s_awaddr == DESC1_NUM_BYTES_OFFSET ) {
			bins low_range  = {[0       : 2730]};   
    		bins mid_range  = {[2731    : 5461]};  
   	 		bins high_range = {[5462    : 8191]};  

		}

	
	dma_desc_cfg_enable_cp: coverpoint axi4l_trx.dma_s_wdata[2]
		iff (axi4l_trx.dma_s_awaddr == DESC0_CFG_OFFSET   || axi4l_trx.dma_s_awaddr == DESC1_CFG_OFFSET ) {
			bins enable     = {1};
			bins not_enable = {0};
	
		}

	dma_desc_rd_cp: coverpoint axi4l_trx.dma_s_wdata[1]
		iff (axi4l_trx.dma_s_awaddr == DESC0_CFG_OFFSET   || axi4l_trx.dma_s_awaddr == DESC1_CFG_OFFSET ) {
			bins rd_fixed = {1};
			bins rd_incr  = {0};
	
		}

	dma_desc_cfg_wr_cp: coverpoint axi4l_trx.dma_s_wdata[0]
		iff (axi4l_trx.dma_s_awaddr == DESC0_CFG_OFFSET   || axi4l_trx.dma_s_awaddr == DESC1_CFG_OFFSET ) {
			bins wr_fixed = {1};
			bins wr_incr  = {0};
	
		}
    
	dma_s_wstrb_cp: coverpoint axi4l_trx.dma_s_wstrb { 
		
		bins strb_is_always_1111  = {4'b1111};
		
		illegal_bins strb_illegal = {//4'b0000,
    								 4'b0001,
    								 4'b0010,
    							     4'b0011,
    								 4'b0100,
    								 4'b0101,
    								 4'b0110,
    								 4'b0111,
    								 4'b1000,
    								 4'b1001,
    								 4'b1010,
    								 4'b1011,
    								 4'b1100,
    								 4'b1101,
    								 4'b1110
  									}; 
	}

    
	dma_s_bresp_cp: coverpoint axi4l_trx.dma_s_bresp { 
		bins        axi4l_wr_okay   = {2'b00};
		ignore_bins axi4l_wr_exokay = {2'b01};
		bins        axi4l_wr_slverr = {2'b10};
		ignore_bins axi4l_wr_decerr = {2'b11};
    }
    
    
	dma_s_araddr_cp: coverpoint axi4l_trx.dma_s_araddr { 
			
		bins dma_control_addr      = {DMA_CONTROL_OFFSET};
  		bins dma_status_addr       = {DMA_STATUS_OFFSET};
  		bins dma_error_addr        = {DMA_ERROR_ADDR_OFFSET};
  		bins dma_error_stats_addr  = {DMA_ERROR_STATS_OFFSET};

  		bins desc0_src_addr        = {DESC0_SRC_OFFSET};
  		bins desc0_dst_addr        = {DESC0_DST_OFFSET};
  		bins desc0_num_bytes_addr  = {DESC0_NUM_BYTES_OFFSET};
  		bins desc0_cfg_addr        = {DESC0_CFG_OFFSET};	
			
		bins desc1_src_addr        = {DESC1_SRC_OFFSET};
  		bins desc1_dst_addr        = {DESC1_DST_OFFSET};
  		bins desc1_num_bytes_addr  = {DESC1_NUM_BYTES_OFFSET};
  		bins desc1_cfg_addr        = {DESC1_CFG_OFFSET};
			
		illegal_bins csr_illegal_rd_addr = default;
			
	}
    
	
	//TODO
	//dma_s_rdata_cp: coverpoint axi4l_trx.dma_s_rdata { bins data_values[] = {[0:$]}; }
    
	dma_s_rresp_cp: coverpoint axi4l_trx.dma_s_rresp {
		bins        axi4l_rd_okay   = {2'b00};
		ignore_bins axi4l_rd_exokay = {2'b01};
		bins        axi4l_rd_slverr = {2'b10};
		ignore_bins axi4l_rd_decerr = {2'b11};
    }
	
  endgroup

//############################################################################

// AXI4-Full
  covergroup dma_cg_axi4; 
    dma_m_awaddr_cp: coverpoint axi4_trx.dma_m_awaddr { 
		bins start_wr_addr = {`START_ADDR};
  		bins low_wr_addr   = {[`START_ADDR+1 : MID_START-1]};
  		bins med_wr_addr   = {[MID_START     : HIGH_START-1]};
  		bins high_wr_addr  = {[HIGH_START    : `END_ADDR-1]};
  		bins end_wr_addr   = {`END_ADDR};	
		
	}

    dma_m_awlen_cp: coverpoint axi4_trx.dma_m_awlen { 
			
	  bins awlen0 = {[  0 :  50]};  
      bins awlen1 = {[ 51 : 101]};  
      bins awlen2 = {[102 : 152]};  
      bins awlen3 = {[153 : 203]};  
      bins awlen4 = {[204 : 255]};   		
			
			
	}

    dma_m_awsize_cp: coverpoint axi4_trx.dma_m_awsize {
      bins        size_1   = {3'b000};
	  ignore_bins size_2   = {3'b001};
	  bins        size_4   = {3'b010};
	  ignore_bins size_8   = {3'b011};
	  ignore_bins size_16  = {3'b100};
	  ignore_bins size_32  = {3'b101};
	  ignore_bins size_64  = {3'b110};
	  ignore_bins size_128 = {3'b111};
    }

    dma_m_awburst_cp: coverpoint axi4_trx.dma_m_awburst {
      bins fixed           = {2'b00};
	  bins incr            = {2'b01};
	  ignore_bins wrap     = {2'b10};
	  ignore_bins reserved = {2'b11};
    }
    
	dma_m_wstrb_cp: coverpoint axi4_trx.dma_m_wstrb {
			bins strb_1111 = {4'b1111};
			bins strb_1110 = {4'b1110};
			bins strb_1100 = {4'b1100};
			bins strb_1000 = {4'b1000};
	
			bins strb_0111 = {4'b0111};
			bins strb_0011 = {4'b0011};
			bins strb_0001 = {4'b0001};

			// Illegal bins
  			//	illegal_bins strb_0000 = {4'b0000};
  			illegal_bins strb_0010 = {4'b0010};
  			illegal_bins strb_0100 = {4'b0100};
  			illegal_bins strb_0101 = {4'b0101};
  			illegal_bins strb_0110 = {4'b0110};
  			illegal_bins strb_1001 = {4'b1001};
  			illegal_bins strb_1010 = {4'b1010};
  			illegal_bins strb_1011 = {4'b1011};
  			illegal_bins strb_1101 = {4'b1101};
	
	}
    
	dma_m_wlast_cp: coverpoint axi4_trx.dma_m_wlast {
      bins wr_last     = {1};
	  bins wr_not_last = {0};
    }
			
	dma_m_bresp_cp: coverpoint axi4_trx.dma_m_bresp {
      bins        wr_okay   = {2'b00};
	  ignore_bins wr_exokay = {2'b01};
	  bins        wr_slverr = {2'b10};
	  ignore_bins wr_decerr = {2'b11};
    }
   
	
	dma_m_araddr_cp: coverpoint axi4_trx.dma_m_araddr { 
			
		bins start_rd_addr = {`START_ADDR};
		bins low_rd_addr   = {[`START_ADDR+1  : MID_START-1]};
		bins med_rd_addr   = {[MID_START      : HIGH_START-1]};
		bins high_rd_addr  = {[HIGH_START     : `END_ADDR-1]};
		bins end_rd_addr   = {`END_ADDR};	
			
	}
    
	
	dma_m_arlen_cp: coverpoint axi4_trx.dma_m_arlen {
	
		
	  bins arlen0 = {[  0 :  50]};  
      bins arlen1 = {[ 51 : 101]};  
      bins arlen2 = {[102 : 152]};  
      bins arlen3 = {[153 : 203]};  
      bins arlen4 = {[204 : 255]};   		
	
	}
    
	
	dma_m_arsize_cp: coverpoint axi4_trx.dma_m_arsize {
      bins        size_1   = {3'b000};
	  ignore_bins size_2   = {3'b001};
	  bins        size_4   = {3'b010};
      ignore_bins size_8   = {3'b011};
	  ignore_bins size_16  = {3'b100};
	  ignore_bins size_32  = {3'b101};
      ignore_bins size_64  = {3'b110};
	  ignore_bins size_128 = {3'b111};
    }
    
	dma_m_arburst_cp: coverpoint axi4_trx.dma_m_arburst {
      bins fixed           = {2'b00};
	  bins incr            = {2'b01};
	  ignore_bins wrap     = {2'b10};
	  ignore_bins reserved = {2'b11};
    }

    dma_m_rresp_cp: coverpoint axi4_trx.dma_m_rresp {
      bins rd_okay   = {2'b00};
	  ignore_bins rd_exokay = {2'b01};
	  bins rd_slverr = {2'b10};
	  ignore_bins rd_decerr = {2'b11};
    }
    
	dma_m_rlast_cp: coverpoint axi4_trx.dma_m_rlast {
      bins rd_last     = {1};
	  bins rd_not_last = {0};
    }

  endgroup

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    dma_cg_lite    = new();
    dma_cg_axi4    = new();
    axi4l_trx_port = new("axi4l_trx_port", this);
    axi4_trx_port  = new("axi4_trx_port", this);
    `uvm_info("axi-cov", "Coverage class constructed", UVM_LOW)
  endfunction

  // AXI4-Lite transaction write
  function void write_axi4l_port(axi4lite_m_seq_item t);
    axi4lite_m_seq_item temp;
    if (!$cast(temp, t)) begin
      `uvm_error(get_name(), "Failed to cast to axi4lite_m_seq_item")
      return;
    end
    axi4l_trx = temp;
    `uvm_info(get_name(), $sformatf("Received from AXI4-Lite Monitor: AWADDR=0x%0h", t.dma_s_awaddr), UVM_NONE)
    dma_cg_lite.sample(); // only uses axi4l_trx
  endfunction

  // AXI4 transaction write
  function void write_axi4_port(axi4_s_seq_item t);
    axi4_s_seq_item temp;
    if (!$cast(temp, t)) begin
      `uvm_error(get_name(), "Failed to cast to axi4_s_seq_item")
      return;
    end
    axi4_trx = temp;
	axi4_trx.print();
    `uvm_info(get_name(), $sformatf("Received from AXI4 Monitor: AWADDR=0x%0h", t.dma_m_awaddr), UVM_NONE)
    dma_cg_axi4.sample(); // only uses axi4_trx
  endfunction

  // Report coverage
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("axi-cov", $sformatf("AXI4-Lite Coverage: %0.2f%%", dma_cg_lite.get_coverage()), UVM_LOW)
    `uvm_info("axi-cov", $sformatf("AXI4 Coverage: %0.2f%%", dma_cg_axi4.get_coverage()), UVM_LOW)
  endfunction

endclass
