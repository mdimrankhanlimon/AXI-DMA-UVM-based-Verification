// ============================================================================
// Project       : AXI-DMA IP Verification
// Component     : AXI4-Lite Monitor
// Developer     : Md. Imran Khan
// Company       : SILICONOVA
// Contact       : imran.limon.99@gmail.com
// ============================================================================
//
// Monitor Features:
// -----------------
//
// 1. Monitors all five AXI4-Lite channels: AW, W, B, AR, and R.
// 2. Captures signal values only during handshake (valid && ready).
// 3. Logs each handshake event to a file with time, channel, address, data, strobe, and response.
// 4. Handles each AXI transaction as an independent thread using fork-join_any.
// 5. Uses `disable fork` to terminate unused threads after the first complete transaction.
// 6. Implements break in every forever loop to avoid deadlocks and allow join_any to proceed.
// 7. Monitors `dma_done_o` and `dma_error_o` independently as a third concurrent thread.
// 8. Detects rising edge of `dma_done_o` or `dma_error_o` for accurate one-time logging per sequence.
// 9. Logs DMA status as a separate `"DMA"` row in the log file with correct timing.
// 10. Filters redundant logging using previous cycle values for dma_done and dma_error.
// 11. Sends each captured transaction through uvm_analysis_port for scoreboard or coverage use.
// 12. Produces human-readable log format with clean column layout and string-safe handling.
// 
// ============================================================================

class axi4lite_monitor extends uvm_monitor;
  `uvm_component_utils(axi4lite_monitor)

  virtual axi4lite_master_if#(.ADDR_WIDTH(32), .DATA_WIDTH(32), .ID_WIDTH(4)) vif;
  uvm_analysis_port#(axi4lite_m_seq_item) ap;

  bit axi4lite_m_mntr_log = 1;
  int file_handle;
  string log_filename = "axi4lite_m_monitor.log";
  int transaction_count;

  bit cur_done;
  bit cur_error;

  bit prev_done = 0;
  bit prev_error = 0;

  function new(string name = "axi4lite_monitor", uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void set_log_file();
    file_handle = $fopen(log_filename, "w");
    if (file_handle == 0)
      `uvm_error(get_type_name(), $sformatf("Failed to open log file: %s", log_filename));
    $fwrite(file_handle, "| ---- | Time (ps)       | Channel  | Address(hex)         | Data(hex)            | Strobe  | Response | Done   | Error  |\n");
    $fwrite(file_handle, "| ---- | --------------- | -------- | -------------------- | -------------------- | ------- | -------- | ------ | ------ |\n");
  endfunction

  function void log_file_write(string channel, time timestamp, axi4lite_m_seq_item txn);
    transaction_count++;
    case (channel)
      "AW": $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20h | %-20s | %-7s | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    txn.dma_s_awaddr, "-", "-", "-", "-", "-");

      "W":  $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20s | %-20h | %-7b | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    "-", txn.dma_s_wdata, txn.dma_s_wstrb, "-", "-", "-");

      "B":  $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20s | %-20s | %-7s | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    "-", "-", "-", (txn.dma_s_bresp ? "ERROR" : "OKAY"), "-", "-");

      "AR": $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20h | %-20s | %-7s | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    txn.dma_s_araddr, "-", "-", "-", "-", "-");

      "R":  $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20s | %-20h | %-7s | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    "-", txn.dma_s_rdata, "-", (txn.dma_s_rresp ? "ERROR" : "OKAY"), "-", "-");

      "DMA": $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20s | %-20s | %-7s | %-8s | %-6b | %-6b |\n",
                    transaction_count, timestamp, channel,
                    "-", "-", "-", "-", txn.dma_done_o, txn.dma_error_o);

      default:
        `uvm_warning(get_name(), ($sformatf("Unknown channel %s in log", channel)))
    endcase
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4lite_master_if)::get(this, "", "AXI4LITE_MASTER_INTF", vif))
      `uvm_error("AXI4_LITE_MON", "No virtual interface specified");

    if (axi4lite_m_mntr_log)
      set_log_file();
    else
      `uvm_warning(get_name(), "Monitor log file not created");
  endfunction

  task run_phase(uvm_phase phase);
    collect_transaction();
  endtask

  task collect_transaction();
    forever begin
      axi4lite_m_seq_item txn = axi4lite_m_seq_item::type_id::create("txn");
      time aw_time, w_time, b_time, ar_time, r_time, ts;

      fork
        // WRITE
        begin
          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_awvalid && vif.master_cb.dma_s_awready) begin
              aw_time = $stime;
              txn.dma_s_awaddr  = vif.master_cb.dma_s_awaddr;
              txn.dma_s_awprot  = vif.master_cb.dma_s_awprot;
              if (axi4lite_m_mntr_log)
                log_file_write("AW", aw_time, txn);
              txn.print();
              break;
            end
          end

          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_wvalid && vif.master_cb.dma_s_wready) begin
              w_time = $stime;
              txn.dma_s_wdata  = vif.master_cb.dma_s_wdata;
              txn.dma_s_wstrb  = vif.master_cb.dma_s_wstrb;
              if (axi4lite_m_mntr_log)
                log_file_write("W", w_time, txn);
              txn.print();
              break;
            end
          end

          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_bvalid && vif.master_cb.dma_s_bready) begin
              b_time = $stime;
              txn.dma_s_bresp  = vif.master_cb.dma_s_bresp;
              if (axi4lite_m_mntr_log)
                log_file_write("B", b_time, txn);
              txn.print();
              ap.write(txn);
              break;
            end
          end
        end

        // READ
        begin
          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_arvalid && vif.master_cb.dma_s_arready) begin
              ar_time = $stime;
              txn.dma_s_araddr  = vif.master_cb.dma_s_araddr;
              txn.dma_s_arprot  = vif.master_cb.dma_s_arprot;
              if (axi4lite_m_mntr_log)
                log_file_write("AR", ar_time, txn);
              txn.print();
              break;
            end
          end

          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_rvalid && vif.master_cb.dma_s_rready) begin
              r_time = $stime;
              txn.dma_s_rdata  = vif.master_cb.dma_s_rdata;
              txn.dma_s_rresp  = vif.master_cb.dma_s_rresp;
              if (axi4lite_m_mntr_log)
                log_file_write("R", r_time, txn);
              txn.print();
              ap.write(txn);
              break;
            end
          end
        end

        // DMA DONE/ERROR logger
        begin
          forever begin
            @(posedge vif.clk);
            cur_done = vif.dma_done_o;
            cur_error = vif.dma_error_o;
            if ((cur_done || cur_error) && !(prev_done || prev_error)) begin
              txn.dma_done_o  = cur_done;
              txn.dma_error_o = cur_error;
              ts = $stime;
              if (axi4lite_m_mntr_log)
                log_file_write("DMA", ts, txn);
              txn.print();
              ap.write(txn);
            end
            prev_done = cur_done;
            prev_error = cur_error;
          end
        end
      join_any
      disable fork;
    end
  endtask

  function void final_phase(uvm_phase phase);
    if (file_handle != 0)
      $fclose(file_handle);
  endfunction

endclass







//with aligned logging (done & error for 1 time, but need to capture for multiple times)
/*
class axi4lite_monitor extends uvm_monitor;
  `uvm_component_utils(axi4lite_monitor)

  virtual axi4lite_master_if#(.ADDR_WIDTH(32), .DATA_WIDTH(32), .ID_WIDTH(4)) vif;
  uvm_analysis_port#(axi4lite_m_seq_item) ap;

  bit axi4lite_m_mntr_log = 1;
  int file_handle;
  string log_filename = "axi4lite_m_monitor.log";
  int transaction_count;

  int count_done_error_f = 0;//flag to capture dma_done, dma_error

  

  function new(string name = "axi4lite_monitor", uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void set_log_file();
    file_handle = $fopen(log_filename, "w");
    if (file_handle == 0)
      `uvm_error(get_type_name(), $sformatf("Failed to open log file: %s", log_filename));
    $fwrite(file_handle, "| ---- | Time (ps)       | Channel  | Address(hex)         | Data(hex)            | Strobe  | Response | Done   | Error  |\n");
    $fwrite(file_handle, "| ---- | --------------- | -------- | -------------------- | -------------------- | ------- | -------- | ------ | ------ |\n");
  endfunction

  function void log_file_write(string channel, time timestamp, axi4lite_m_seq_item txn);
    transaction_count++;
    case (channel)
      "AW": $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20h | %-20s | %-7s | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    txn.dma_s_awaddr, "-", "-", "-", "-", "-");

      "W":  $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20s | %-20h | %-7b | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    "-", txn.dma_s_wdata, txn.dma_s_wstrb, "-", "-", "-");

      "B":  $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20s | %-20s | %-7s | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    "-", "-", "-", (txn.dma_s_bresp ? "ERROR" : "OKAY"), "-", "-");

      "AR": $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20h | %-20s | %-7s | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    txn.dma_s_araddr, "-", "-", "-", "-", "-");

      "R":  $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20s | %-20h | %-7s | %-8s | %-6s | %-6s |\n",
                    transaction_count, timestamp, channel,
                    "-", txn.dma_s_rdata, "-", (txn.dma_s_rresp ? "ERROR" : "OKAY"), "-", "-");

      "DMA": $fwrite(file_handle, "| %-4d | %-15t | %-8s | %-20s | %-20s | %-7s | %-8s | %-6b | %-6b |\n",
                    transaction_count, timestamp, channel,
                    "-", "-", "-", "-", txn.dma_done_o, txn.dma_error_o);

      default:
        `uvm_warning(get_name(), ($sformatf("Unknown channel %s in log", channel)))
    endcase
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4lite_master_if)::get(this, "", "AXI4LITE_MASTER_INTF", vif))
      `uvm_error("AXI4_LITE_MON", "No virtual interface specified");

    if (axi4lite_m_mntr_log)
      set_log_file();
    else
      `uvm_warning(get_name(), "Monitor log file not created");
  endfunction

  task run_phase(uvm_phase phase);
			
			collect_transaction();
    
  endtask

  task collect_transaction();
    forever begin
      axi4lite_m_seq_item txn = axi4lite_m_seq_item::type_id::create("txn");
      time aw_time, w_time, b_time, ar_time, r_time, ts;

      fork
        // WRITE
        begin
          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_awvalid && vif.master_cb.dma_s_awready) begin
              aw_time = $stime;
              txn.dma_s_awaddr  = vif.master_cb.dma_s_awaddr;
              txn.dma_s_awprot  = vif.master_cb.dma_s_awprot;
              //txn.dma_s_awvalid = 1;
              if (axi4lite_m_mntr_log)
                log_file_write("AW", aw_time, txn);
              txn.print();
              break;
            end
          end

          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_wvalid && vif.master_cb.dma_s_wready) begin
              w_time = $stime;
              txn.dma_s_wdata  = vif.master_cb.dma_s_wdata;
              txn.dma_s_wstrb  = vif.master_cb.dma_s_wstrb;
              //txn.dma_s_wlast  = vif.master_cb.dma_s_wlast;
              //txn.dma_s_wvalid = 1;
              if (axi4lite_m_mntr_log)
                log_file_write("W", w_time, txn);
              txn.print();
              break;
            end
          end

          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_bvalid && vif.master_cb.dma_s_bready) begin
              b_time = $stime;
              txn.dma_s_bresp  = vif.master_cb.dma_s_bresp;
              //txn.dma_s_bvalid = 1;
              if (axi4lite_m_mntr_log)
                log_file_write("B", b_time, txn);
              txn.print();
              ap.write(txn);
              break;
            end
          end
        end

        // READ
        begin
          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_arvalid && vif.master_cb.dma_s_arready) begin
              ar_time = $stime;
              txn.dma_s_araddr  = vif.master_cb.dma_s_araddr;
              txn.dma_s_arprot  = vif.master_cb.dma_s_arprot;
              //txn.dma_s_arvalid = 1;
              if (axi4lite_m_mntr_log)
                log_file_write("AR", ar_time, txn);
              txn.print();
              break;
            end
          end

          forever begin @(posedge vif.clk);
            if (vif.master_cb.dma_s_rvalid && vif.master_cb.dma_s_rready) begin
              r_time = $stime;
              txn.dma_s_rdata  = vif.master_cb.dma_s_rdata;
              txn.dma_s_rresp  = vif.master_cb.dma_s_rresp;
              //txn.dma_s_rvalid = 1;
              if (axi4lite_m_mntr_log)
                log_file_write("R", r_time, txn);
              txn.print();
              ap.write(txn);
              break;
            end
          end
        end

        // DMA DONE/ERROR logger
      begin        	
        forever begin
		    @(posedge vif.clk);           
            if ((vif.dma_done_o == 1  ) || (vif.dma_error_o == 1  )) begin
            //axi4lite_m_seq_item dma_txn = axi4lite_m_seq_item::type_id::create("dma_txn");
				if (!count_done_error_f) begin
					txn.dma_done_o  = vif.dma_done_o;
            		txn.dma_error_o = vif.dma_error_o;
            		ts = $stime;
            		if (axi4lite_m_mntr_log) log_file_write("DMA", ts, txn);

            		txn.print();
            		ap.write(txn);
					count_done_error_f = 1;
	            end
            end
        end
      end
      join_any
      disable fork;
    end
  endtask

  function void final_phase(uvm_phase phase);
    if (file_handle != 0)
      $fclose(file_handle);
  endfunction

endclass
*/







//sample withoue done/error
//##########################17-04-2025##########################
/*
class axi4lite_monitor extends uvm_monitor;
  `uvm_component_utils(axi4lite_monitor)

  virtual  axi4lite_master_if#(.ADDR_WIDTH(32), .DATA_WIDTH(32), .ID_WIDTH(4)) vif;
  //axi4lite_m_seq_item txn;
  uvm_analysis_port#(axi4lite_m_seq_item) ap;
  
  // transaction tracing
  //int ok;

  // variable declaration for Log file 
  bit axi4lite_m_mntr_log=1;
  int file_handle;
  string log_filename = "axi4lite_m_monitor.log"; 
  //int start_time;
  //int end_time;
  int transaction_count;

  // Events for channel handshakes
  uvm_event aw_done, w_done, b_done;
  uvm_event ar_done, r_done;

  function new(string name = "axi4lite_monitor", uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);

    aw_done = new();
    w_done  = new();
    b_done  = new();
    ar_done = new();
    r_done  = new();

  endfunction

  // Function to open the log file
  function void set_log_file();
    file_handle = $fopen(log_filename, "w");
    if (file_handle == 0)
        `uvm_error(get_type_name(), $sformatf("Failed to open log file: %s", log_filename));
        $fwrite(file_handle, "| ---- | --------------- | --------------- | ------- | ------------------- | ------------------ | ----------------- | ---------------- | ----------- | \n");
        $fwrite(file_handle, "| SL   | Start Time (ps) | End Time (ps)   | Strobe  | Write_Address (hex) | Read_Address (hex) | Write_Data (hex)  | Read_Data (hex)  | Response    | \n");
        $fwrite(file_handle, "| ---- | --------------- | --------------- | ------- | ------------------- | ------------------ | ----------------- | ---------------- | ----------- | \n");
  endfunction

  // function to write log file 
  function void log_file_write(axi4lite_m_seq_item txn, time start_time, time end_time);
      transaction_count++;// count the transactions

      // Logging in the specified format
      $fwrite(file_handle, "| %-4d | %-15t | %-15t | %-07b | %-19h | %-18h | %-17h | %-16h | %-11s | \n",
          transaction_count, start_time, end_time, txn.dma_s_wstrb, txn.dma_s_awaddr, txn.dma_s_araddr,
          txn.dma_s_wdata, txn.dma_s_rdata,
          (txn.dma_s_bresp ? "ERROR" : "OKAY"));
      $fwrite(file_handle, "| ---- | --------------- | --------------- | ------- | ------------------- | ------------------ | ----------------- | ---------------- | ----------- | \n");
  endfunction 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4lite_master_if)::get(this, "", "AXI4LITE_MASTER_INTF", vif))
      `uvm_error("AXI4_LITE_MON", "No virtual interface specified");

    `uvm_info(get_name(), $sformatf("value of mntr_log: %0d", axi4lite_m_mntr_log), UVM_NONE);
    if(axi4lite_m_mntr_log) begin 
	set_log_file();
    end
    else `uvm_warning(get_name(), "Monitor log file not created")

  endfunction

  task run_phase(uvm_phase phase);
     //forever begin
      collect_transaction();
     //end
  endtask



  task collect_transaction();	  
    forever begin
	  time start_time, end_time;
	 axi4lite_m_seq_item txn = axi4lite_m_seq_item::type_id::create("txn");     
	 @(posedge vif.clk);
      //if (!vif.rst_n) continue;

      fork        
        begin     	  
	      if (vif.master_cb.dma_s_awvalid && vif.master_cb.dma_s_awready) begin
		  start_time = $stime;
	      `uvm_info(get_name(), $sformatf("aw channel handshake completed"), UVM_NONE);
          txn.dma_s_awaddr = vif.master_cb.dma_s_awaddr;
          txn.dma_s_awprot = vif.master_cb.dma_s_awprot;
          txn.dma_s_awvalid = vif.master_cb.dma_s_awvalid;
	      end
        end

        // Monitor Write Data Channel (W)
        begin
          if (vif.master_cb.dma_s_wvalid && vif.master_cb.dma_s_wready) begin
	      `uvm_info(get_name(), $sformatf("w channel handshake completed"), UVM_NONE);
          txn.dma_s_wdata = vif.master_cb.dma_s_wdata;
          txn.dma_s_wstrb = vif.master_cb.dma_s_wstrb;
          txn.dma_s_wvalid = vif.master_cb.dma_s_wvalid;
          txn.dma_s_wlast = vif.master_cb.dma_s_wlast;      	  
	     `uvm_info(get_name(), $sformatf(" vif.master_cb.dma_s_wdata = %d ",vif.master_cb.dma_s_wdata), UVM_NONE);

	     `uvm_info(get_name(), $sformatf(" txn.dma_s_wdata = %h || txn.dma_s_wstrb =%h || txn.dma_s_wvalid =%h || txn.dma_s_wlast =%h",txn.dma_s_wdata, txn.dma_s_wstrb, txn.dma_s_wvalid, txn.dma_s_wlast), UVM_NONE);
	  	  end
        end

        // Monitor Write Response Channel (B)
        begin
          if (vif.master_cb.dma_s_bvalid && vif.master_cb.dma_s_bready) begin
	      `uvm_info(get_name(), $sformatf("B channel handshake completed"), UVM_NONE);
          txn.dma_s_bresp = vif.master_cb.dma_s_bresp;
          txn.dma_s_bvalid = vif.master_cb.dma_s_bvalid;
          txn.dma_s_bready = vif.master_cb.dma_s_bready;
	  	  end
        end

        // Monitor Read Address Channel (AR)
        begin      	  
          if (vif.master_cb.dma_s_arvalid && vif.master_cb.dma_s_arready) begin
		  `uvm_info(get_name(), $sformatf("AR channel handshake completed"), UVM_NONE);
          txn.dma_s_araddr = vif.master_cb.dma_s_araddr;
          txn.dma_s_arprot = vif.master_cb.dma_s_arprot;
          txn.dma_s_arvalid = vif.master_cb.dma_s_arvalid;
      	  end
        end

        // Monitor Read Data Channel (R)
        begin
      	  if (vif.master_cb.dma_s_rvalid && vif.master_cb.dma_s_rready) begin
	      `uvm_info(get_name(), $sformatf("R channel handshake completed"), UVM_NONE);
          txn.dma_s_rdata = vif.master_cb.dma_s_rdata;
          txn.dma_s_rresp = vif.master_cb.dma_s_rresp;
          txn.dma_s_rvalid = vif.master_cb.dma_s_rvalid;
          txn.dma_s_rlast = vif.master_cb.dma_s_rlast;
	      `uvm_info(get_name(), $sformatf(" txn.dma_s_rdata = %h || txn.dma_s_rresp =%h || txn.dma_s_rvalid =%h || txn.dma_s_rlast =%h",txn.dma_s_rdata, txn.dma_s_rresp, txn.dma_s_rvalid, txn.dma_s_rlast), UVM_NONE);	  
	      end
        end
      join

	  end_time = $stime;
      // writing log file
      if(axi4lite_m_mntr_log) begin
        log_file_write(txn, start_time, end_time);
      end
      	  
    end 
endtask


  // Close the log file at the end of simulation
  function void final_phase(uvm_phase phase);
      if (file_handle != 0)
          $fclose(file_handle);                           
  endfunction

endclass
*/




