/////////////////////////////////////////////////
// Project:   AXI-DMA verification
// Component: AXI-LITE Driver
// Developer: amit.sikder@siliconova.com
// Date:      12.02.2025
// Modified on:
/////////////////////////////////////////////////

class axi4lite_m_driver extends uvm_driver #(axi4lite_m_seq_item);
  `uvm_component_utils(axi4lite_m_driver)

  // Virtual interface for AXI signals
  virtual axi4lite_master_if axi4lite_m_intf;

  virtual clk_rst_interface clk_intf;

  // Sequence item 
  axi4lite_m_seq_item item;

  // Constructor
  function new (string name = "axi4lite_m_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual axi4lite_master_if)::get(this, "*", "AXI4LITE_MASTER_INTF", axi4lite_m_intf)) begin
      `uvm_error(get_full_name(), "Could not get AXI slave interface from driver")
    end
    // Retrieve the virtual interface for AXI from the config database
    if (!uvm_config_db #(virtual clk_rst_interface)::get(this, "*", "CLK_RST_INTF", clk_intf)) begin
      `uvm_error(get_full_name(), "Could not get clk-reset interface from driver")
    end
  endfunction

  // Task to reset the AXI interface signals
  task reset_intf();
    `uvm_info(get_name(), "Driving reset", UVM_HIGH)
    // Assert reset signal and clear all AXI interface signals
    clk_intf.rst_n <= 1;
    axi4lite_m_intf.dma_s_awaddr <= 0;
    axi4lite_m_intf.dma_s_awprot <= 0;
    axi4lite_m_intf.dma_s_awvalid <= 0;
    axi4lite_m_intf.dma_s_wdata <= 0;
    axi4lite_m_intf.dma_s_wstrb <= 0;
    axi4lite_m_intf.dma_s_wvalid <= 0;
    axi4lite_m_intf.dma_s_bready <= 0;
    axi4lite_m_intf.dma_s_araddr <= 0;
    axi4lite_m_intf.dma_s_arprot <= 0;
    axi4lite_m_intf.dma_s_arvalid <= 0;
    axi4lite_m_intf.dma_s_rready <= 0;
    axi4lite_m_intf.dma_s_wlast <= 0;

    `uvm_info(get_name(), "Waiting for reset deassertion", UVM_HIGH)
    @(negedge clk_intf.clk);  // Wait for a clock cycle
    clk_intf.rst_n <= 0;      // De-asserting the reset signal
    `uvm_info(get_name(), "Reset Complete", UVM_HIGH)
  endtask

  // Task to drive the write address channel (AWADDR, AWVALID)
  virtual task drive_write_address(axi4lite_m_seq_item item, virtual axi4lite_master_if intf);
    int cycle_count = 0;  // Veriable for cycle count
    // Assign the write address and control signals for write operation
    `uvm_info(get_name(), "Driving write address task", UVM_NONE)
    intf.dma_s_awaddr <= item.dma_s_awaddr;
    intf.dma_s_awprot <= item.dma_s_awprot;
    intf.dma_s_awvalid <= 1'b1;
    // Wait for AWREADY signal to be asserted
    do 
      begin
        if (intf.dma_s_awready) begin
          `uvm_info(get_name(), "AWREADY received from Interface", UVM_NONE)
          @(negedge clk_intf.clk);
          break;
        end
        cycle_count ++;
        if (cycle_count > 20) begin
          `uvm_error (get_name(), "Didn't get AWREADY high more than 20 cycle")
          break;
        end
        @(posedge clk_intf.clk);
      end while (1);
    intf.dma_s_awvalid <= 1'b0;  // Deassert AWVALID after receiving AWREADY
  endtask

  // Task to drive the write data channel (WDATA, WSTRB) for write operation
  virtual task drive_write_data(axi4lite_m_seq_item item, virtual axi4lite_master_if intf);
    int cycle_count = 0;  // Veriable for cycle count
    // Assign the write data and control signals for write operation
    `uvm_info(get_name(), "Driving write data task", UVM_NONE)
    intf.dma_s_wdata <= item.dma_s_wdata;
    intf.dma_s_wstrb <= item.dma_s_wstrb;
    intf.dma_s_wvalid <= 1'b1;
    // Wait for WREADY signal to be asserted
    do 
      begin
        if (intf.dma_s_wready) begin
          `uvm_info(get_name(), "WREADY received from Interface", UVM_HIGH)
          @(negedge clk_intf.clk);
          break;
        end
        cycle_count ++;
        if (cycle_count > 20) begin
          `uvm_error (get_name(), "Didn't get WREADY high more than 20 cycle")
          break;
        end
        @(posedge clk_intf.clk);
      end while (1);
    intf.dma_s_wvalid <= 1'b0;
  endtask

  // Task to drive the write response channel (BRESP, BVALID)
  virtual task drive_write_response(axi4lite_m_seq_item item, virtual axi4lite_master_if intf);
    int cycle_count = 0;  // Veriable for cycle count
    `uvm_info(get_name(), "Driving write response task", UVM_NONE)
    intf.dma_s_bready <= 1'b1;
    // Wait for BVALID signal to be asserted
    do 
      begin
        if (intf.dma_s_bvalid) begin
          `uvm_info(get_name(), "BVALID received from Interface", UVM_HIGH)
          @(negedge clk_intf.clk);
          break;
        end
        cycle_count ++;
        if (cycle_count > 20) begin
          `uvm_error (get_name(), "Didn't get BVALID high more than 20 cycle")
          break;
        end
        @(posedge clk_intf.clk);
      end while (1);
    item.dma_s_bresp <= intf.dma_s_bresp; // Capture the write response
    intf.dma_s_bready <= 1'b0; // Deassert BREADY after receiving response
  endtask

  // Task to drive the read address channel (ARADDR, ARVALID)
  virtual task drive_read_address(axi4lite_m_seq_item item, virtual axi4lite_master_if intf);
    int cycle_count = 0;  // Veriable for cycle count
    `uvm_info(get_name(), "Driving read address task", UVM_NONE)
    intf.dma_s_araddr <= item.dma_s_araddr;
    intf.dma_s_arprot <= item.dma_s_arprot;
    intf.dma_s_arvalid <= 1'b1;
    // Wait for ARREADY signal to be asserted
    do 
      begin
        if (intf.dma_s_arready) begin
          `uvm_info(get_name(), "ARREADY received from Interface", UVM_HIGH)
          @(negedge clk_intf.clk);
          break;
        end
        cycle_count ++;
        if (cycle_count > 20) begin
          `uvm_error (get_name(), "Didn't get ARREADY high more than 20 cycle")
          break;
        end
        @(posedge clk_intf.clk);
      end while (1);
    intf.dma_s_arvalid <= 1'b0;  // Deassert ARVALID after receiving ARREADY
  endtask

  // Task to handle the read data channel (RDATA, RRESP) for read operation
  virtual task drive_read_data(axi4lite_m_seq_item item, virtual axi4lite_master_if intf);
    int cycle_count = 0;  // Veriable for cycle count
    `uvm_info(get_name(), "Driving read data task", UVM_NONE)
    intf.dma_s_rready <= 1'b1;
    // Wait for RVALID signal to be asserted
    do 
      begin
        if (intf.dma_s_rvalid) begin
          `uvm_info(get_name(), "RVALID received from Interface", UVM_HIGH)
          @(negedge clk_intf.clk);
          break;
        end
        cycle_count ++;
        if (cycle_count > 20) begin
          `uvm_error (get_name(), "Didn't get RVALID high more than 20 cycle")
          break;
        end
        @(posedge clk_intf.clk);
      end while (1);
    item.dma_s_rdata <= intf.dma_s_rdata; // Capture the read data - optional from driver
    item.dma_s_rresp <= intf.dma_s_rresp; // Capture the read response - optional from driver
    intf.dma_s_rready <= 1'b0;  // Deassert RREADY after reading data
  endtask

  // Main task to drive the AXI transaction
  virtual task drive(axi4lite_m_seq_item item);
    if (item.WRITE && item.READ) begin     // If read and write operation asserts together
      fork                                          
        drive_write_data(item, axi4lite_m_intf);
        drive_write_response(item, axi4lite_m_intf);
        drive_read_address(item, axi4lite_m_intf);
        drive_read_data(item, axi4lite_m_intf);
        drive_write_address(item, axi4lite_m_intf);
      join
    end else if (item.READ) begin
      `uvm_info(get_name(), "READ channel calling...", UVM_NONE)
      // Read operation: address phase and data phase
      drive_read_address(item, axi4lite_m_intf);
      drive_read_data(item, axi4lite_m_intf);
    end else if (item.WRITE) begin     // item.READ is a user-define variable to control read and write channel
      // Write operation: address phase, data phase, and response phase
      `uvm_info(get_name(), "WRITE channel calling...", UVM_NONE)
      drive_write_address(item, axi4lite_m_intf);
      drive_write_data(item, axi4lite_m_intf);
      drive_write_response(item, axi4lite_m_intf);
    end  
  endtask

  // Run phase
  virtual task run_phase(uvm_phase phase);
    forever begin
      `uvm_info(get_name(), "Waiting for sequence item from sequencer", UVM_NONE)
      seq_item_port.get_next_item(item);  // Get next item from sequencer
      `uvm_info(get_name(), "Received Item from Sequencer", UVM_NONE)
      `uvm_info(get_name(), $sformatf("value of READ = %0d, value of WRITE = %0d", item.READ, item.WRITE), UVM_NONE)
      if (!item.rst_n) begin
        // If reset sequence is detected
        `uvm_info(get_name(), "Reset sequence detected by driver", UVM_NONE)
        reset_intf();  // Reset the AXI interface
        `uvm_info(get_name(), "Reset completed", UVM_NONE)
      end else begin
        // Drive regular sequence
        `uvm_info(get_name(), "Driving read/write sequence", UVM_NONE)
        drive(item);  // Drive the AXI transaction
        `uvm_info(get_name(), "Driving read/write sequence completed", UVM_NONE)
      end

      `uvm_info(get_name(), "Sequence item driving done", UVM_NONE)
      seq_item_port.item_done();  // Mark item as done
    end
  endtask

endclass
