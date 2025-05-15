/////////////////////////////////////////////////
// Project:   AXI-DMA verification
// Component: AXI4 Monitor
// Developer: amit.sikder@siliconova.com
// Date:      11.04.2025
// Modified on: 23.04.2025
/////////////////////////////////////////////////

class axi4_s_monitor extends uvm_component;
  `uvm_component_utils(axi4_s_monitor)

  // Virtual interface handles (to be set via config_db)
  virtual axi4_slave_if axi4_s_intf;
  virtual clk_rst_interface clk_intf;

  // Analysis port to broadcast observed transactions to other UVM components (e.g., scoreboard)
  uvm_analysis_port #(axi4_s_seq_item) axi4_s_mntr_port;

  // Control flag: enable or disable transaction logging to a file
  bit axi4_s_mntr_log;

  // File handle for the log file
  int file_handle;

  // Name of the log file
  string log_filename = "axi4_s_monitor.log";

  // Counter to keep track of the number of transactions monitored
  int transaction_count;

  // Address queues to hold outstanding read/write requests for matching with data phase
  int 	rd_queue [$];
  int 	wr_queue [$];
  int wr_bln_queue[$];
  int rd_bln_queue[$];

  // Constructor
  function new(string name = "axi4_s_monitor", uvm_component parent);
    super.new(name, parent);
    axi4_s_mntr_port = new("axi4_s_mntr_port", this); // Create analysis port
  endfunction

  // Build phase: fetch interface handles and setup logging
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get virtual interface for AXI signals
    if (!uvm_config_db#(virtual axi4_slave_if)::get(this, "*", "AXI4_SLAVE_INTF", axi4_s_intf))
      `uvm_fatal(get_full_name(), "Could not get AXI interface from config DB")

    // Get virtual interface for clock/reset signals
    if (!uvm_config_db#(virtual clk_rst_interface)::get(this, "*", "CLK_RST_INTF", clk_intf))
      `uvm_fatal(get_full_name(), "Could not get clk/rst interface from config DB")

    // If logging is enabled, open the log file
    if (axi4_s_mntr_log) set_log_file();
  endfunction

// Function to open and prepare the log file with header formatting
  function void set_log_file();
    file_handle = $fopen(log_filename, "w");
    if (file_handle == 0)
      `uvm_error(get_type_name(), "Failed to open log file")
  
    // Write the log header with column names
    $fwrite(file_handle, "+------+-------------+-------------+-------+----------------+--------+--------------+--------+-------+-------+--------+--------+\n");
    $fwrite(file_handle, "| SL   | Start Time  | End Time    | Type  | Address        | Length | Data (Hex)   | WSTRB  | WLAST | RLAST | WRESP  | RRESP  |\n");
    $fwrite(file_handle, "+------+-------------+-------------+-------+----------------+--------+--------------+--------+-------+-------+--------+--------+\n");
  endfunction
  
  // Function to format and log one complete transaction with WRESP/RRESP split
  function automatic void log_transaction(axi4_s_seq_item item, time start_time, time end_time);
    string type_str;
    string data_str;
    string wstrb_str;
    string wresp_str;
    string rresp_str;
    bit [31:0] addr;
  
    transaction_count++; // Increment transaction count
  
    // Identify type and data
    type_str  = item.WRITE ? "WRITE" : "READ";
    data_str  = $sformatf("%h", item.WRITE ? item.dma_m_wdata : item.dma_m_rdata);
    wstrb_str = item.WRITE ? $sformatf("%04b", item.dma_m_wstrb) : "----";
  
    // Only display WRESP if WRITE + WLAST is set
    wresp_str = (item.WRITE && item.dma_m_wlast && item.dma_m_bresp == 2'b00) ? "OKAY" :
                (item.WRITE && item.dma_m_wlast) ? "ERROR" : "-----";
  
    // Always display RRESP for every READ transaction
    rresp_str = (item.READ && item.dma_m_rresp == 2'b00) ? "OKAY" : 
                (item.READ) ? "ERROR" : "-----";
  
    // Write formatted transaction row
    $fwrite(file_handle,
      "| %-4d | %-11t | %-11t | %-5s | %08h       | %2d     | %-12s | %-6s |   %-1d   |   %-1d   | %-6s | %-6s |\n",
      transaction_count,
      start_time,
      end_time,
      type_str,
      item.WRITE ? item.dma_m_awaddr : item.dma_m_araddr,
      item.WRITE ? (item.dma_m_awlen + 1) : (item.dma_m_arlen + 1),
      data_str,
      wstrb_str,
      item.WRITE ? item.dma_m_wlast : 0,
      item.READ  ? item.dma_m_rlast : 0,
      wresp_str,
      rresp_str
    );
  
    // Add spacing and separator after each transaction
    $fwrite(file_handle, "|      |             |             |       |                |        |              |        |       |       |        |        |\n");
    $fwrite(file_handle, "+------+-------------+-------------+-------+----------------+--------+--------------+--------+-------+-------+--------+--------+\n");
  endfunction
  
  

  // Run phase: concurrent read and write monitoring tasks
  task run_phase(uvm_phase phase);
    fork
      monitor_write();
      monitor_read();
    join
  endtask

  // Monitor read channel: AR + R phase
  task monitor_read();
    int i;
    int address;
    time start_time, end_time;
    axi4_s_seq_item item = axi4_s_seq_item::type_id::create("item"); // Create transaction item

    fork
      // Track AR channel for incoming read address
      forever begin
        if(axi4_s_intf.dma_m_arvalid && axi4_s_intf.dma_m_arready) begin
          item.READ = 1;
          rd_bln_queue.push_front(axi4_s_intf.dma_m_arlen);
          item.dma_m_arsize  = axi4_s_intf.dma_m_arsize;
          item.dma_m_arid   = axi4_s_intf.dma_m_arid;
          item.dma_m_arburst   = axi4_s_intf.dma_m_arburst;

          rd_queue.push_front(axi4_s_intf.dma_m_araddr); // Save address for R channel tracking

          `uvm_info("AR-mntr", $sformatf("address: %0xh", axi4_s_intf.dma_m_araddr), UVM_NONE)
        end
        @(posedge clk_intf.CLK_1);
      end

      // Track R channel for read data
      forever begin
        if(axi4_s_intf.dma_m_rvalid && axi4_s_intf.dma_m_rready) begin
          `uvm_info("R-mntr", $sformatf("0%t, handshaking done!", $time), UVM_LOW)
          item.READ = 1;
          item.dma_m_araddr = rd_queue.pop_back(); // Get corresponding address from AR
          address = item.dma_m_araddr;
          if(rd_bln_queue.size != 0) begin
            item.dma_m_arlen = rd_bln_queue.pop_back();  
          end

          for (i = 0; i <= item.dma_m_arlen; i++) begin
            start_time = $time;
            @(negedge clk_intf.CLK_1);

            // Capture read data and status
            item.dma_m_rdata  = axi4_s_intf.dma_m_rdata;
            item.dma_m_rresp  = axi4_s_intf.dma_m_rresp;
            item.dma_m_rid    = axi4_s_intf.dma_m_rid;
            if(i == item.dma_m_arlen) begin
              item.dma_m_rlast  = 1;
            end
            item.dma_m_araddr = address;
            `uvm_info("R-mntr", $sformatf("raddress = %0h, rdata = %0h, rresp = %0h", item.dma_m_araddr, item.dma_m_rdata, item.dma_m_rresp), UVM_HIGH)

            if(item.dma_m_arburst == 'b01) begin
              address = address + 'h4;
            end
            end_time = $time;
            // Send transaction to port and log
            if (axi4_s_mntr_log) log_transaction(item, start_time, end_time);
            axi4_s_mntr_port.write(item);
          end
          item.READ = 0;
        end
        @(posedge clk_intf.CLK_1);
      end
    join
  endtask

  // Monitor write channel: AW + W phase
  task monitor_write();
    int i;
    int waddress;
    time start_time, end_time;
    axi4_s_seq_item item = axi4_s_seq_item::type_id::create("item");

    fork
      // Track AW channel for write address
      forever begin
        if(axi4_s_intf.dma_m_awvalid && axi4_s_intf.dma_m_awready) begin
          @(posedge clk_intf.CLK_1);
          item.WRITE = 1;
          wr_queue.push_front(axi4_s_intf.dma_m_awaddr);
          wr_bln_queue.push_front(axi4_s_intf.dma_m_awlen);
          item.dma_m_awburst  = axi4_s_intf.dma_m_awburst;
          item.dma_m_awid   = axi4_s_intf.dma_m_awid;
          item.dma_m_awsize = axi4_s_intf.dma_m_awsize;

          `uvm_info("AW-mntr", $sformatf("address: %0xh", item.dma_m_awaddr), UVM_NONE)
        end
        @(negedge clk_intf.CLK_1);
      end

      // Track W channel for write data
      forever begin
        if (axi4_s_intf.dma_m_wvalid && axi4_s_intf.dma_m_wready) begin
          item.WRITE = 1;
          wait(wr_queue.size() > 0);
          item.dma_m_awaddr = wr_queue.pop_back(); // Match address with AW phase
          waddress = item.dma_m_awaddr;
          
          if(wr_bln_queue.size != 0) begin
            item.dma_m_awlen = wr_bln_queue.pop_back();  
          end

          for(i = 0; i<= item.dma_m_awlen; i++) begin
            start_time = $time;

            // Capture write data and strobe
            item.dma_m_wdata  = axi4_s_intf.dma_m_wdata;
            item.dma_m_wstrb  = axi4_s_intf.dma_m_wstrb;
            item.dma_m_wvalid = axi4_s_intf.dma_m_wvalid;
            item.dma_m_wlast  = axi4_s_intf.dma_m_wlast;
            item.dma_m_awaddr = waddress;
            item.dma_m_bresp  = axi4_s_intf.dma_m_bresp;

            `uvm_info("W-mntr", $sformatf("0%t, address: %0xh bresp: %0h", $time, item.dma_m_awaddr, item.dma_m_bresp), UVM_HIGH)

            @(negedge clk_intf.CLK_1);
            if (item.dma_m_awburst == 'b01) begin
              waddress = waddress + 'h4;
            end
            end_time = $time;

            // Send transaction to port and log
            axi4_s_mntr_port.write(item);
            if (axi4_s_mntr_log) log_transaction(item, start_time, end_time);
          end
        end
        @(posedge clk_intf.CLK_1);
        item.WRITE = 0;
      end
    join
  endtask

  // Final phase: close the log file
  function void final_phase(uvm_phase phase);
    if (file_handle) $fclose(file_handle);
  endfunction

endclass