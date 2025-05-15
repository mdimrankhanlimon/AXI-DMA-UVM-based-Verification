/////////////////////////////////////////////////
// Project:   AXI-DMA verification
// Component: AXI4 Driver
// Developer: amit.sikder@siliconova.com
// Date:      28.02.2025
// Modified on: 23.04.2025
/////////////////////////////////////////////////

class axi4_s_driver extends uvm_driver #(axi4_s_seq_item);
  `uvm_component_utils(axi4_s_driver) 

  // Virtual interfaces
  virtual axi4_slave_if axi4_s_intf;  
  virtual clk_rst_interface clk_intf;

  axi4_s_seq_item item;                 // Transaction item (though unused in reactive drivers)

  // Internal memory arrays (simulate memory model)
  bit [31:0] mem [0:10240];  
  //bit [31:0] mem1 [3072:5120];

  // Queues to track outstanding read/write requests
  int rd_queue [$]; 
  int wr_queue [$]; 
  int wr_bln_queue[$];
  int rd_bln_queue[$];
  int bresp_queue[$];

  // Loop and state counters
  int i, j;
  int m, n;

  // Internal flags for status tracking
  bit awready, wready, arready;

  // Temporary address/data variables
  bit [31:0] waddress;
  bit [31:0] wdata;
  bit [31:0] raddress;
  bit [31:0] rdata;

  // Variables to store AXI burst parameters
  bit [7:0] wr_burst_length;
  bit [1:0] wr_burst_type;
  bit [2:0] wr_burst_size;
  bit [7:0] rd_burst_length;
  bit [1:0] rd_burst_type;
  bit [2:0] rd_burst_size;

  // Constructor
  function new(string name = "axi4_s_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase to fetch virtual interfaces
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual axi4_slave_if)::get(this, "*", "AXI4_SLAVE_INTF", axi4_s_intf))
      `uvm_error(get_full_name(), "Could not get AXI interface from driver")
    if (!uvm_config_db #(virtual clk_rst_interface)::get(this, "*", "CLK_RST_INTF", clk_intf))
      `uvm_error(get_full_name(), "Could not get clk-reset interface from driver")
  endfunction

  // Fill initial memory with random values
  function void mem_write();
    foreach (mem[i]) begin
      mem[i] = $urandom;
    end
  endfunction

  // Run phase  the heart of the reactive driver
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_name(), "Inside run phase of reactive driver", UVM_NONE)

    // Reset all AXI slave output signals
    axi4_s_intf.dma_m_awready = 0;
    axi4_s_intf.dma_m_wready  = 0;
    axi4_s_intf.dma_m_bvalid  = 0;
    axi4_s_intf.dma_m_bresp   = 2'b00;
    axi4_s_intf.dma_m_arready = 0;
    axi4_s_intf.dma_m_rvalid  = 0;
    axi4_s_intf.dma_m_rdata   = 0;
    axi4_s_intf.dma_m_rlast   = 0;
    axi4_s_intf.dma_m_rresp   = 2'b00;
    axi4_s_intf.dma_m_ruser   = 0;
    axi4_s_intf.dma_m_rid     = 0;
    axi4_s_intf.dma_m_buser   = 0;

    // Preload memory with random values
    mem_write();

    fork
      // -------------------------
      // WRITE ADDRESS CHANNEL
      // -------------------------
      begin
        forever begin
          if(!axi4_s_intf.dma_m_awvalid) axi4_s_intf.dma_m_awready = 0;         // Deassert ready if no valid
          axi4_s_intf.dma_m_awready = 1;
          
          if(axi4_s_intf.dma_m_awvalid) begin                                     // Wait for valid signal from master
            wr_queue.push_front(axi4_s_intf.dma_m_awaddr);                      // Store address for write queue
            wr_bln_queue.push_front(axi4_s_intf.dma_m_awlen);
            wr_burst_type   = axi4_s_intf.dma_m_awburst;
            wr_burst_size   = axi4_s_intf.dma_m_awsize;
            `uvm_info("AW-debug", $sformatf("wr_queue[0] = %0h", rd_queue[0]), UVM_NONE)
          end
          @(negedge clk_intf.CLK_1);
        end
      end

      // -------------------------
      // WRITE DATA CHANNEL
      // -------------------------
      begin
        forever begin
          axi4_s_intf.dma_m_wready  = 0;
          if(axi4_s_intf.dma_m_wvalid) begin                                    // Wait for valid data
            `uvm_info("W-debug", $sformatf("before the wait state-> queue_size = %0d, wr_queue[0] = %0h", wr_queue.size(), wr_queue[0]), UVM_LOW)
            axi4_s_intf.dma_m_wready  = 0;
            wait((wr_queue.size() > 0));  
            axi4_s_intf.dma_m_wready  = 1;                                      // Ensure address is ready
            `uvm_info("W-debug", $sformatf("wr_queue size = %0d, length = %0d", wr_queue.size(), wr_burst_length), UVM_LOW)

            waddress = wr_queue.pop_back();                                     // Get the stored address
            if(wr_bln_queue.size != 0) begin
              wr_burst_length = wr_bln_queue.pop_back();  
            end

              // Loop through burst
              for (j = 0; j <= wr_burst_length; j++) begin
                `uvm_info("W-debug", $sformatf("W -> incr Address = 0x%0h", waddress), UVM_LOW)
                `uvm_info("W-debug", $sformatf("inside the loop! j = %0d", j), UVM_LOW)
                @(posedge clk_intf.CLK_1);
                //wready = 0;
                mem[waddress] = axi4_s_intf.dma_m_wdata;                         // Write to memory
                `uvm_info("W-debug", $sformatf("W -> address: %0h, data: %0h", waddress, axi4_s_intf.dma_m_wdata), UVM_NONE) 
                `uvm_info("W-debug", $sformatf("W -> data: %0h", mem[waddress]), UVM_NONE) 
                if(wr_burst_type == 'b01) begin
                  waddress = waddress + 'h4;  
                end                                      // Increment address
              end
              wready = 1;
              bresp_queue.push_front(wready);                                                         // Set write complete flag
              `uvm_info("W-debug", "outside the loop", UVM_LOW)
            end
          @(negedge clk_intf.CLK_1);
        end
      end

      // -------------------------
      // WRITE RESPONSE CHANNEL
      // -------------------------
      begin
        forever begin
          if (bresp_queue.size > 0) begin
            axi4_s_intf.dma_m_bresp  = AXI_OKAY;
            axi4_s_intf.dma_m_bvalid = 1;
            `uvm_info(get_name(), "B -> Response sent with OKAY", UVM_LOW);
            @(posedge clk_intf.CLK_1 iff axi4_s_intf.dma_m_bready);       // Wait for ready again
            axi4_s_intf.dma_m_bvalid <= 0;
            wready = 0; 
            bresp_queue.pop_back();
          end else if (waddress > 'd10240) begin
            axi4_s_intf.dma_m_bresp  <= AXI_SLVERR;
            axi4_s_intf.dma_m_bvalid <= 1;
          end
          @(negedge clk_intf.CLK_1);
        end
      end

      // -------------------------
      // READ ADDRESS CHANNEL
      // -------------------------
      begin
        forever begin
          if (axi4_s_intf.dma_m_arvalid) begin
            axi4_s_intf.dma_m_arready = 1;
            //rd_burst_length = axi4_s_intf.dma_m_arlen;
            rd_queue.push_front(axi4_s_intf.dma_m_araddr);
            rd_bln_queue.push_front(axi4_s_intf.dma_m_arlen);
            rd_burst_size   = axi4_s_intf.dma_m_arsize;
            rd_burst_type = axi4_s_intf.dma_m_arburst;
            `uvm_info("AR-debug", $sformatf("rd_queue[0] = %0h", rd_queue[0]), UVM_NONE)
          end
          @(negedge clk_intf.CLK_1);
        end
      end

      // -------------------------
      // READ DATA CHANNEL
      // -------------------------
      begin
        forever begin
          `uvm_info("R-debug", "inside the R channel", UVM_LOW)
          axi4_s_intf.dma_m_rlast  = 0;
          axi4_s_intf.dma_m_rvalid <= 0;

          if(axi4_s_intf.dma_m_rready) begin                                 // Wait for slave to be ready
            axi4_s_intf.dma_m_rid    = 0;
            axi4_s_intf.dma_m_ruser  = 0;
            `uvm_info("R-debug", $sformatf("before the wait state-> queue_size = %0d, rd_queue[0] = %0h", rd_queue.size(), rd_queue[0]), UVM_HIGH)
            
            wait((rd_queue.size() > 0));                                    // Wait for valid address
            `uvm_info("R-debug", $sformatf("R -> rd_queue size = %0d, length = %0d", rd_queue.size(), rd_burst_length), UVM_LOW)
            raddress = rd_queue.pop_back();

            if(rd_bln_queue.size != 0) begin
              rd_burst_length = rd_bln_queue.pop_back();
            end
              
              for (i = 0; i <= rd_burst_length; i++) begin
                `uvm_info("R-debug", $sformatf("AR -> incr Address = 0x%0h", raddress), UVM_LOW)
                `uvm_info("R-debug", $sformatf("inside the loop! i = %0d", i), UVM_LOW)
                @(negedge clk_intf.CLK_1);
                axi4_s_intf.dma_m_rvalid = 1;
                axi4_s_intf.dma_m_rdata  = mem[raddress]; 
                axi4_s_intf.dma_m_rlast  = 0;
                `uvm_info("R-debug", $sformatf("R -> address: %0h, data: %0h", raddress, mem[raddress]), UVM_NONE)
                if(rd_burst_type == 'b01) begin
                  raddress = raddress + 'h4;
                  if(raddress > 'd10240) begin
                    `uvm_info("R-debug", $sformatf("R -> inside the address error"), UVM_NONE)
                    axi4_s_intf.dma_m_rresp  = AXI_SLVERR;
                  end else begin
                    axi4_s_intf.dma_m_rresp  = 2'b00;                               // Response OKAY
                  end
                end
                `uvm_info("R-debug", $sformatf("0%t ns, R -> rlast = %0d", $time, axi4_s_intf.dma_m_rlast), UVM_LOW) 
              end
              `uvm_info("R-debug", "outside the loop", UVM_LOW)
              axi4_s_intf.dma_m_rlast  = 1;                                  // Final data
          end
          @(posedge clk_intf.CLK_1);
        end
      end
    join
  endtask

endclass

class axi_s_error_driver extends axi4_s_driver;
  `uvm_component_utils(axi_s_error_driver)

  function new (string name = "axi_s_error_driver", uvm_component parent = null);
    super.new(name,parent);
  endfunction

 // Run phase  the heart of the reactive driver
  virtual task run_phase(uvm_phase phase);
    //super.run_phase(phase);
    `uvm_info("Err-Driver", "Inside run phase of error driver", UVM_NONE)

    // Reset all AXI slave output signals
    axi4_s_intf.dma_m_awready = 0;
    axi4_s_intf.dma_m_wready  = 0;
    axi4_s_intf.dma_m_bvalid  = 0;
    axi4_s_intf.dma_m_bresp   = 2'b00;
    axi4_s_intf.dma_m_arready = 0;
    axi4_s_intf.dma_m_rvalid  = 0;
    axi4_s_intf.dma_m_rdata   = 0;
    axi4_s_intf.dma_m_rlast   = 0;
    axi4_s_intf.dma_m_rresp   = 2'b00;
    axi4_s_intf.dma_m_ruser   = 0;
    axi4_s_intf.dma_m_rid     = 0;
    axi4_s_intf.dma_m_buser   = 0;

    // Preload memory with random values
    mem_write();

    fork
      // -------------------------
      // WRITE ADDRESS CHANNEL
      // -------------------------
      begin
        forever begin
          if(!axi4_s_intf.dma_m_awvalid) axi4_s_intf.dma_m_awready = 0;         // Deassert ready if no valid
          axi4_s_intf.dma_m_awready = 1;
          
          if(axi4_s_intf.dma_m_awvalid) begin                                     // Wait for valid signal from master
            wr_queue.push_front(axi4_s_intf.dma_m_awaddr);                      // Store address for write queue
            wr_bln_queue.push_front(axi4_s_intf.dma_m_awlen);
            wr_burst_type   = axi4_s_intf.dma_m_awburst;
            wr_burst_size   = axi4_s_intf.dma_m_awsize;
            `uvm_info("AW-debug", $sformatf("wr_queue[0] = %0h", rd_queue[0]), UVM_NONE)
          end
          @(negedge clk_intf.CLK_1);
        end
      end

      // -------------------------
      // WRITE DATA CHANNEL
      // -------------------------
      begin
        forever begin
          axi4_s_intf.dma_m_wready  = 0;
          if(axi4_s_intf.dma_m_wvalid) begin                                    // Wait for valid data
            `uvm_info("W-debug", $sformatf("before the wait state-> queue_size = %0d, wr_queue[0] = %0h", wr_queue.size(), wr_queue[0]), UVM_LOW)
            axi4_s_intf.dma_m_wready  = 0;
            wait((wr_queue.size() > 0));  
            axi4_s_intf.dma_m_wready  = 1;                                      // Ensure address is ready
            `uvm_info("W-debug", $sformatf("wr_queue size = %0d, length = %0d", wr_queue.size(), wr_burst_length), UVM_LOW)

            waddress = wr_queue.pop_back();                                     // Get the stored address
            if(wr_bln_queue.size != 0) begin
              wr_burst_length = wr_bln_queue.pop_back();  
            end

              // Loop through burst
              for (j = 0; j <= wr_burst_length; j++) begin
                `uvm_info("W-debug", $sformatf("W -> incr Address = 0x%0h", waddress), UVM_LOW)
                `uvm_info("W-debug", $sformatf("inside the loop! j = %0d", j), UVM_LOW)
                @(posedge clk_intf.CLK_1);
                wready = 0;
                mem[waddress] = axi4_s_intf.dma_m_wdata;                         // Write to memory
                `uvm_info("W-debug", $sformatf("W -> address: %0h, data: %0h", waddress, axi4_s_intf.dma_m_wdata), UVM_NONE) 
                `uvm_info("W-debug", $sformatf("W -> data: %0h", mem[waddress]), UVM_NONE) 
                if(wr_burst_type == 'b01) begin
                  waddress = waddress + 'h4;  
                end                                      // Increment address
              end
              wready = 1;                                                         // Set write complete flag
              `uvm_info("W-debug", "outside the loop", UVM_LOW)
            end
          @(negedge clk_intf.CLK_1);
        end
      end

      // -------------------------
      // WRITE RESPONSE CHANNEL
      // -------------------------
      begin
        forever begin
          @(negedge clk_intf.CLK_1);
          if (wready && axi4_s_intf.dma_m_bready) begin
            axi4_s_intf.dma_m_bresp  = AXI_SLVERR;
            axi4_s_intf.dma_m_bvalid = 1;
            `uvm_info(get_name(), "B -> Response sent with ERROR", UVM_LOW);
            @(negedge clk_intf.CLK_1 iff axi4_s_intf.dma_m_bready);       // Wait for ready again
            axi4_s_intf.dma_m_bvalid <= 0;
            wready = 0; 
          end 
        end
      end

      // -------------------------
      // READ ADDRESS CHANNEL
      // -------------------------
      begin
        forever begin
          if (axi4_s_intf.dma_m_arvalid) begin
            axi4_s_intf.dma_m_arready = 1;
            rd_burst_length = axi4_s_intf.dma_m_arlen;
            rd_queue.push_front(axi4_s_intf.dma_m_araddr);
            rd_burst_size   = axi4_s_intf.dma_m_arsize;
            rd_burst_type = axi4_s_intf.dma_m_arburst;
            `uvm_info("AR-debug", $sformatf("rd_queue[0] = %0h", rd_queue[0]), UVM_NONE)
          end
          @(negedge clk_intf.CLK_1);
        end
      end

      // -------------------------
      // READ DATA CHANNEL
      // -------------------------
      begin
        forever begin
          `uvm_info("R-debug", "inside the R channel", UVM_LOW)
          axi4_s_intf.dma_m_rlast  = 0;
          axi4_s_intf.dma_m_rvalid = 0;

          if(axi4_s_intf.dma_m_rready) begin                                 // Wait for slave to be ready
            axi4_s_intf.dma_m_rid    = 0;
            axi4_s_intf.dma_m_ruser  = 0;

            `uvm_info("R-debug", $sformatf("before the wait state-> queue_size = %0d, rd_queue[0] = %0h", rd_queue.size(), rd_queue[0]), UVM_HIGH)
            
            wait((rd_queue.size() > 0));                                    // Wait for valid address
            `uvm_info("R-debug", $sformatf("R -> rd_queue size = %0d, length = %0d", rd_queue.size(), rd_burst_length), UVM_LOW)
            raddress = rd_queue.pop_back();
            axi4_s_intf.dma_m_rvalid = 1;
              
              for (i = 0; i <= rd_burst_length; i++) begin
                `uvm_info("R-debug", $sformatf("AR -> incr Address = 0x%0h", raddress), UVM_LOW)
                `uvm_info("R-debug", $sformatf("inside the loop! i = %0d", i), UVM_LOW)
                @(negedge clk_intf.CLK_1);
                //axi4_s_intf.dma_m_rvalid = 1;
                axi4_s_intf.dma_m_rdata  = mem[raddress]; 
                axi4_s_intf.dma_m_rlast  = 0;
                axi4_s_intf.dma_m_rresp  = AXI_SLVERR;
                `uvm_info("R-debug", $sformatf("R -> address: %0h, data: %0h", raddress, mem[raddress]), UVM_NONE)
                if(rd_burst_type == 'b01) begin
                  raddress = raddress + 'h4;
                end
                `uvm_info("R-debug", $sformatf("0%t ns, R -> rlast = %0d", $time, axi4_s_intf.dma_m_rlast), UVM_LOW) 
              end
              `uvm_info("R-debug", "outside the loop", UVM_LOW)
              axi4_s_intf.dma_m_rlast  = 1;                                  // Final data
          end
          @(posedge clk_intf.CLK_1);
        end
      end
    join
  endtask
endclass
