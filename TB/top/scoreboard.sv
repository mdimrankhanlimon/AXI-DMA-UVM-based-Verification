// ============================================================================
// Project       : AXI-DMA IP Verification
// Component     : Scoreboard
// Developer     : Md. Imran Khan
// Company       : SILICONOVA
// Contact       : imran.limon.99@gmail.com
// ============================================================================
//
// Scoreboard Features:
// --------------------
//
// 1. Matches source and destination addresses at the beginning of each DMA sequence.
// 2. Handles unaligned data transfer using WSTRB and verifies data byte-by-byte.
// 3. Tracks total bytes read and written per DMA sequence.
// 4. Supports multiple DMA sequences issued back-to-back without interfering matches.
// 5. Separately queues and synchronizes num_byte, dma_done, and dma_error events.
// 6. Waits for dma_done before triggering end-of-transfer matching.
// 7. Prints mismatch or success logs per sequence with byte-level detail.
// 8. Handles ABORT condition via CSR and halts verification accordingly.
// 9. Uses SystemVerilog queues to maintain sequence state and allow pipelining.
//
// ============================================================================


//final version
`uvm_analysis_imp_decl(_axil_csr_ap)
`uvm_analysis_imp_decl(_axi_transaction_ap)

class dma_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dma_scoreboard)

  bit [31:0] source_memory[int];
  bit [31:0] destination_memory[int];

  bit [31:0] source_address;
  bit [31:0] destination_address;

  int num_byte_q[$];
  bit dma_done_q[$];
  bit dma_error_q[$];

  int rd_queue[$];
  int total_bytes_read = 0;
  int total_bytes_written = 0;

  bit source_addr_checked = 0;
  bit dest_addr_checked = 0;
  bit abort_flag = 0;

  uvm_analysis_imp_axil_csr_ap #(axi4lite_m_seq_item, dma_scoreboard) axil_csr_ap;
  uvm_analysis_imp_axi_transaction_ap #(axi4_s_seq_item, dma_scoreboard) axi_transaction_ap;

  function new(string name = "dma_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    axil_csr_ap = new("axil_csr_ap", this);
    axi_transaction_ap = new("axi_transaction_ap", this);
  endfunction

  function void write_axil_csr_ap(axi4lite_m_seq_item t);
    case (t.dma_s_awaddr)
      32'h00: begin
        if (t.dma_s_wdata[1]) begin
          abort_flag = 1;
          `uvm_warning("CSR", "?? ABORT received. Transfer verification will stop.");
        end
      end
      32'h20: begin
        source_address = t.dma_s_wdata;
      end
      32'h30: begin
        destination_address = t.dma_s_wdata;
      end
      32'h40: begin
        num_byte_q.push_back(t.dma_s_wdata);
      end
    endcase

    if (t.dma_done_o || t.dma_error_o) begin
      dma_done_q.push_back(t.dma_done_o);
      dma_error_q.push_back(t.dma_error_o);
      `uvm_info("CSR", $sformatf("Pushed DMA Status: done=%0b, error=%0b", t.dma_done_o, t.dma_error_o), UVM_LOW);

      // Match on DMA done inside CSR function
      if (num_byte_q.size() > 0 && dma_done_q.size() > 0 && dma_done_q[0] == 1) begin
        int cfg_num_byte = num_byte_q.pop_front();
        bit cfg_done     = dma_done_q.pop_front();
        bit cfg_error    = dma_error_q.pop_front();

        `uvm_info("axi4-scb", $sformatf("TO CHECK :: cfg_num_byte = %0d, cfg_done = %0d", cfg_num_byte, cfg_done), UVM_NONE);
        `uvm_info("axi4-scb", $sformatf("Checking sequence with num_byte = %0d", cfg_num_byte), UVM_NONE);

        if (total_bytes_read == cfg_num_byte && total_bytes_written == cfg_num_byte) begin
          `uvm_info("axi4-scb", $sformatf("? DMA DONE - Transfer matched for num_byte = %0d", cfg_num_byte), UVM_NONE);
        end else begin
          if (total_bytes_read != cfg_num_byte) begin
            `uvm_warning("axi4-scb", $sformatf("? Read mismatch! Got %0d, Expected %0d", total_bytes_read, cfg_num_byte));
          end
          if (total_bytes_written != cfg_num_byte) begin
            `uvm_warning("axi4-scb", $sformatf("? Write mismatch! Got %0d, Expected %0d", total_bytes_written, cfg_num_byte));
          end
        end

        if (cfg_error) begin
          `uvm_warning("axi4-scb", "?? DMA completed with ERROR");
        end

        total_bytes_read    = 0;
        total_bytes_written = 0;
        source_addr_checked = 0;
        dest_addr_checked   = 0;
      end
    end

    `uvm_info("CSR", $sformatf("Set Source=0x%0h, Destination=0x%0h", source_address, destination_address), UVM_NONE);
  endfunction

  function void write_axi_transaction_ap(axi4_s_seq_item t);
    int beat_size;
    beat_size = 1 << 2;

    if (abort_flag) begin
      `uvm_warning("axi4-scb", "Skipping AXI transaction due to ABORT flag.");
      return;
    end

    if (t.READ == 1) begin
      `uvm_info("axi4-scb", $sformatf("READ -> Addr: 0x%0h, Data: 0x%0h", t.dma_m_araddr, t.dma_m_rdata), UVM_NONE);
      rd_queue.push_front(t.dma_m_rdata);
      total_bytes_read += beat_size;
      `uvm_info("axi4-scb", $sformatf("total_bytes_read = %0d", total_bytes_read), UVM_NONE);

      if (!source_addr_checked) begin
        if (t.dma_m_araddr !== source_address) begin
          `uvm_warning("axi4-scb", $sformatf("Read from unexpected source address. Expected: 0x%0h, Got: 0x%0h", source_address, t.dma_m_araddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Source address match confirmed: 0x%0h", t.dma_m_araddr), UVM_NONE);
        end
        source_addr_checked = 1;
      end

    end else if (t.WRITE == 1) begin
      `uvm_info("axi4-scb", $sformatf("WRITE -> Addr: 0x%0h, Data: 0x%0h, WSTRB: %b", t.dma_m_awaddr, t.dma_m_wdata, t.dma_m_wstrb), UVM_NONE);
      total_bytes_written += beat_size;
      `uvm_info("axi4-scb", $sformatf("total_bytes_written = %0d", total_bytes_written), UVM_NONE);

      if (!dest_addr_checked) begin
        if (t.dma_m_awaddr !== destination_address) begin
          `uvm_warning("axi4-scb", $sformatf("Write to unexpected destination address. Expected: 0x%0h, Got: 0x%0h", destination_address, t.dma_m_awaddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Destination address match confirmed: 0x%0h", t.dma_m_awaddr), UVM_NONE);
        end
        dest_addr_checked = 1;
      end

      if (rd_queue.size() == 0) begin
        `uvm_warning("axi4-scb", "Write occurred before corresponding read! Read queue is empty.");
      end else begin
        int expected = rd_queue.pop_back();

        for (int i = 0; i < 4; i++) begin
          if (t.dma_m_wstrb[i]) begin
            bit [7:0] expected_byte = expected >> (i * 8);
            bit [7:0] written_byte  = t.dma_m_wdata >> (i * 8);
            if (expected_byte !== written_byte) begin
              `uvm_warning("axi4-scb", $sformatf("? Byte[%0d] Mismatch! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte));
            end else begin
              `uvm_info("axi4-scb", $sformatf("? Byte[%0d] Data Matched! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte), UVM_NONE);
            end
          end
        end
        `uvm_info("axi4-scb", "? Write data verification complete (WSTRB-based match)", UVM_NONE);
      end
    end else begin
      `uvm_info("axi4-scb", "Unknown transaction detected", UVM_NONE);
    end
  endfunction

  function void reset_queues();
    rd_queue.delete();
    source_address = 0;
    destination_address = 0;
    total_bytes_read = 0;
    total_bytes_written = 0;
    source_addr_checked = 0;
    dest_addr_checked = 0;
    abort_flag = 0;
    num_byte_q.delete();
    dma_done_q.delete();
    dma_error_q.delete();
    `uvm_info("RESET", "Scoreboard state cleared.", UVM_LOW);
  endfunction
endclass



//done pushing 0 & 1 both, not going num_byte match block
/*
`uvm_analysis_imp_decl(_axil_csr_ap)
`uvm_analysis_imp_decl(_axi_transaction_ap)

class dma_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dma_scoreboard)

  bit [31:0] source_memory[int];
  bit [31:0] destination_memory[int];

  bit [31:0] source_address;
  bit [31:0] destination_address;

  bit [31:0] num_byte_q[$];
  bit dma_done_q[$];
  bit dma_error_q[$];

  int rd_queue[$];
  int total_bytes_read = 0;
  int total_bytes_written = 0;

  bit source_addr_checked = 0;
  bit dest_addr_checked = 0;
  bit abort_flag = 0;

  uvm_analysis_imp_axil_csr_ap #(axi4lite_m_seq_item, dma_scoreboard) axil_csr_ap;
  uvm_analysis_imp_axi_transaction_ap #(axi4_s_seq_item, dma_scoreboard) axi_transaction_ap;

  function new(string name = "dma_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    axil_csr_ap = new("axil_csr_ap", this);
    axi_transaction_ap = new("axi_transaction_ap", this);
  endfunction

  function void write_axil_csr_ap(axi4lite_m_seq_item t);
    case (t.dma_s_awaddr)
      32'h00: begin
        if (t.dma_s_wdata[1]) begin
          abort_flag = 1;
          `uvm_warning("CSR", "?? ABORT received. Transfer verification will stop.");
        end
      end
      32'h20: source_address = t.dma_s_wdata;
      32'h30: destination_address = t.dma_s_wdata;
      32'h40: num_byte_q.push_back(t.dma_s_wdata);
    endcase

    dma_done_q.push_back(t.dma_done_o);
    dma_error_q.push_back(t.dma_error_o);



`uvm_info("CSR", $sformatf("----- DMA Sequence Queue Snapshot -----"), UVM_NONE)
foreach (dma_done_q[i]) begin
  $display("Index %0d: num_byte = %0d, dma_done = %0b, dma_error = %0b",
           i, num_byte_q[i], dma_done_q[i], dma_error_q[i]);
end



    `uvm_info("CSR", $sformatf("Captured DMA Config: num_byte_q size = %0d, dma_done_q size = %0d", num_byte_q.size(), dma_done_q.size()), UVM_LOW)
    `uvm_info("CSR", $sformatf("Set Source=0x%0h, Destination=0x%0h", source_address, destination_address), UVM_NONE)
  endfunction

  function void write_axi_transaction_ap(axi4_s_seq_item t);
    int beat_size;
    if (abort_flag) begin
      `uvm_warning("axi4-scb", "Skipping AXI transaction due to ABORT flag.");
      return;
    end

    beat_size = 1 << 2;

    if (t.READ == 1) begin
      `uvm_info("axi4-scb", $sformatf("READ -> Addr: 0x%0h, Data: 0x%0h", t.dma_m_araddr, t.dma_m_rdata), UVM_NONE);
      rd_queue.push_front(t.dma_m_rdata);
      total_bytes_read += beat_size;
      `uvm_info("axi4-scb", $sformatf("total_bytes_read = %0d", total_bytes_read), UVM_LOW);

      if (!source_addr_checked) begin
        if (t.dma_m_araddr !== source_address) begin
          `uvm_warning("axi4-scb", $sformatf("Read from unexpected source address. Expected: 0x%0h, Got: 0x%0h", source_address, t.dma_m_araddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Source address match confirmed: 0x%0h", t.dma_m_araddr), UVM_NONE);
        end
        source_addr_checked = 1;
      end

    end else if (t.WRITE == 1) begin
      `uvm_info("axi4-scb", $sformatf("WRITE -> Addr: 0x%0h, Data: 0x%0h, WSTRB: %b", t.dma_m_awaddr, t.dma_m_wdata, t.dma_m_wstrb), UVM_NONE);
      total_bytes_written += beat_size;
      `uvm_info("axi4-scb", $sformatf("total_bytes_written = %0d", total_bytes_written), UVM_LOW);

      if (!dest_addr_checked) begin
        if (t.dma_m_awaddr !== destination_address) begin
          `uvm_warning("axi4-scb", $sformatf("Write to unexpected destination address. Expected: 0x%0h, Got: 0x%0h", destination_address, t.dma_m_awaddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Destination address match confirmed: 0x%0h", t.dma_m_awaddr), UVM_NONE);
        end
        dest_addr_checked = 1;
      end

      if (rd_queue.size() == 0) begin
        `uvm_error("axi4-scb", "Write occurred before corresponding read! Read queue is empty.");
      end else begin
        int expected = rd_queue.pop_back();
        for (int i = 0; i < 4; i++) begin
          if (t.dma_m_wstrb[i]) begin
            bit [7:0] expected_byte = expected >> (i * 8);
            bit [7:0] written_byte  = t.dma_m_wdata >> (i * 8);
            if (expected_byte !== written_byte) begin
              `uvm_error("axi4-scb", $sformatf("? Byte[%0d] Mismatch! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte));
            end else begin
              `uvm_info("axi4-scb", $sformatf("? Byte[%0d] Data Matched! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte), UVM_NONE);
            end
          end
        end
        `uvm_info("axi4-scb", "? Write data verification complete (WSTRB-based match)", UVM_NONE);
      end

      if (dma_done_q.size() > 0 && dma_done_q[0]) begin
        if (num_byte_q.size() > 0) begin
          bit [31:0] current_num_byte = num_byte_q.pop_front();
          bit current_error = dma_error_q.pop_front();
          dma_done_q.pop_front();

          if (total_bytes_read == current_num_byte && total_bytes_written == current_num_byte) begin
            `uvm_info("axi4-scb", $sformatf("? DMA DONE - Transfer matched for num_byte = %0d", current_num_byte), UVM_NONE);
          end else begin
            if (total_bytes_read != current_num_byte)
              `uvm_error("axi4-scb", $sformatf("? Read mismatch! Got %0d, Expected %0d", total_bytes_read, current_num_byte));
            if (total_bytes_written != current_num_byte)
              `uvm_error("axi4-scb", $sformatf("? Write mismatch! Got %0d, Expected %0d", total_bytes_written, current_num_byte));
          end

          if (current_error)
            `uvm_warning("axi4-scb", "?? DMA completed with ERROR");

          total_bytes_read    = 0;
          total_bytes_written = 0;
          source_addr_checked = 0;
          dest_addr_checked   = 0;
        end else begin
          `uvm_warning("axi4-scb", "DMA_DONE received but no corresponding num_byte in queue");
        end
      end
    end else begin
      `uvm_info("axi4-scb","Unknown transaction detected", UVM_NONE);
    end
  endfunction

  function void reset_queues();
    rd_queue.delete();
    source_address = 0;
    destination_address = 0;
    num_byte_q.delete();
    dma_done_q.delete();
    dma_error_q.delete();
    total_bytes_read = 0;
    total_bytes_written = 0;
    source_addr_checked = 0;
    dest_addr_checked = 0;
    abort_flag = 0;
    `uvm_info("RESET", "Scoreboard state cleared.", UVM_LOW);
  endfunction
endclass
*/








//not working, pushing num_byte problem
/*
`uvm_analysis_imp_decl(_axil_csr_ap)
`uvm_analysis_imp_decl(_axi_transaction_ap)

class dma_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dma_scoreboard)

  // Memory Models to track source data and read-back data
  bit [31:0] source_memory[int];      // Stores data read from source address
  bit [31:0] destination_memory[int]; // Stores data read back from destination address

  bit [31:0] source_address;
  bit [31:0] destination_address;

  typedef struct packed {
    bit [31:0] num_byte;
    bit        dma_done;
    bit        dma_error;
  } dma_cfg_t;

  dma_cfg_t cfg_q[$];
  dma_cfg_t pending_cfg;
  dma_cfg_t cfg;

  int rd_queue[$];
  int total_bytes_read = 0;
  int total_bytes_written = 0;

  bit source_addr_checked = 0;
  bit dest_addr_checked   = 0;
  bit abort_flag          = 0;

  uvm_analysis_imp_axil_csr_ap #(axi4lite_m_seq_item, dma_scoreboard) axil_csr_ap;
  uvm_analysis_imp_axi_transaction_ap #(axi4_s_seq_item, dma_scoreboard) axi_transaction_ap;

  function new(string name = "dma_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    axil_csr_ap = new("axil_csr_ap", this);
    axi_transaction_ap = new("axi_transaction_ap", this);
  endfunction

  function void write_axil_csr_ap(axi4lite_m_seq_item t);
    case (t.dma_s_awaddr)
      32'h00: begin
        if (t.dma_s_wdata[1]) begin
          abort_flag = 1;
          `uvm_warning("CSR", "?? ABORT received. Transfer verification will stop.");
        end
      end
      32'h20: source_address = t.dma_s_wdata;
      32'h30: destination_address = t.dma_s_wdata;
      32'h40: pending_cfg.num_byte = t.dma_s_wdata;
    endcase

    // Done/error monitored regardless of AWADDR
    if (t.dma_done_o || t.dma_error_o) begin
      pending_cfg.dma_done  = t.dma_done_o;
      pending_cfg.dma_error = t.dma_error_o;
      cfg_q.push_back(pending_cfg);

      `uvm_info("CSR", $sformatf("? Pushed DMA Config: num_byte=%0d, done=%0b, error=%0b",
        pending_cfg.num_byte, pending_cfg.dma_done, pending_cfg.dma_error), UVM_LOW)

      pending_cfg = '{default:0};
    end

    `uvm_info("CSR", $sformatf("Set Source=0x%0h, Destination=0x%0h", source_address, destination_address), UVM_NONE)
  endfunction

  function void write_axi_transaction_ap(axi4_s_seq_item t);
    int beat_size = 1 << 2;

    if (abort_flag) begin
      `uvm_warning("axi4-scb", "Skipping AXI transaction due to ABORT flag.");
      return;
    end

    if (t.READ == 1) begin
      `uvm_info("axi4-scb", $sformatf("READ -> Addr: 0x%0h, Data: 0x%0h", t.dma_m_araddr, t.dma_m_rdata), UVM_NONE);
      rd_queue.push_front(t.dma_m_rdata);
      total_bytes_read += beat_size;
      `uvm_info("axi4-scb", $sformatf("total_bytes_read = %0d", total_bytes_read), UVM_NONE);

      if (!source_addr_checked) begin
        if (t.dma_m_araddr !== source_address) begin
          `uvm_warning("axi4-scb", $sformatf("Read from unexpected source address. Expected: 0x%0h, Got: 0x%0h", source_address, t.dma_m_araddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Source address match confirmed: 0x%0h", t.dma_m_araddr), UVM_NONE);
        end
        source_addr_checked = 1;
      end

    end else if (t.WRITE == 1) begin
      `uvm_info("axi4-scb", $sformatf("WRITE -> Addr: 0x%0h, Data: 0x%0h, WSTRB: %b", t.dma_m_awaddr, t.dma_m_wdata, t.dma_m_wstrb), UVM_NONE);
      total_bytes_written += beat_size;
      `uvm_info("axi4-scb", $sformatf("total_bytes_written = %0d", total_bytes_written), UVM_NONE);

      if (!dest_addr_checked) begin
        if (t.dma_m_awaddr !== destination_address) begin
          `uvm_warning("axi4-scb", $sformatf("Write to unexpected destination address. Expected: 0x%0h, Got: 0x%0h", destination_address, t.dma_m_awaddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Destination address match confirmed: 0x%0h", t.dma_m_awaddr), UVM_NONE);
        end
        dest_addr_checked = 1;
      end

      if (rd_queue.size() == 0) begin
        `uvm_error("axi4-scb", "Write occurred before corresponding read! Read queue is empty.");
      end else begin
        int expected = rd_queue.pop_back();
        for (int i = 0; i < 4; i++) begin
          if (t.dma_m_wstrb[i]) begin
            bit [7:0] expected_byte = expected >> (i * 8);
            bit [7:0] written_byte  = t.dma_m_wdata >> (i * 8);
            if (expected_byte !== written_byte) begin
              `uvm_error("axi4-scb", $sformatf("? Byte[%0d] Mismatch! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte));
            end else begin
              `uvm_info("axi4-scb", $sformatf("? Byte[%0d] Data Matched! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte), UVM_NONE);
            end
          end
        end
        `uvm_info("axi4-scb", "? Write data verification complete (WSTRB-based match)", UVM_NONE);
      end

      // Match per DMA sequence config (only if done is received)
      if (cfg_q.size() > 0 && cfg_q[0].dma_done) begin


`uvm_info("axi4-scb", $sformatf("Checking DMA DONE window. total_bytes_read = %0d, total_bytes_written = %0d", total_bytes_read, total_bytes_written), UVM_LOW)

foreach (cfg_q[i]) begin
  $display("cfg_q[%0d] = '{num_byte: %0d, dma_done: %0b, dma_error: %0b}", 
           i, cfg_q[i].num_byte, cfg_q[i].dma_done, cfg_q[i].dma_error);
end


         cfg = cfg_q.pop_front();

        if (total_bytes_read == cfg.num_byte && total_bytes_written == cfg.num_byte) begin
          `uvm_info("axi4-scb", $sformatf("? DMA DONE - Transfer matched for num_byte = %0d", cfg.num_byte), UVM_NONE);
        end else begin
          if (total_bytes_read != cfg.num_byte)
            `uvm_error("axi4-scb", $sformatf("? Read mismatch! Got %0d, Expected %0d", total_bytes_read, cfg.num_byte));
          if (total_bytes_written != cfg.num_byte)
            `uvm_error("axi4-scb", $sformatf("? Write mismatch! Got %0d, Expected %0d", total_bytes_written, cfg.num_byte));
        end

        if (cfg.dma_error)
          `uvm_warning("axi4-scb", "?? DMA completed with ERROR");

        // Reset per sequence
        total_bytes_read    = 0;
        total_bytes_written = 0;
        source_addr_checked = 0;
        dest_addr_checked   = 0;
      end

    end else begin
      `uvm_info("axi4-scb", "Unknown transaction detected", UVM_NONE);
    end
  endfunction

  function void reset_queues();
    rd_queue.delete();
    cfg_q.delete();
    source_address = 0;
    destination_address = 0;
    total_bytes_read = 0;
    total_bytes_written = 0;
    source_addr_checked = 0;
    dest_addr_checked = 0;
    abort_flag = 0;
    pending_cfg = '{default:0};
    `uvm_info("RESET", "Scoreboard state cleared.", UVM_LOW);
  endfunction
endclass
*/




//old one, 1 fail
/*
`uvm_analysis_imp_decl(_axil_csr_ap)
`uvm_analysis_imp_decl(_axi_transaction_ap)

class dma_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dma_scoreboard)

  // Memory Models to track source data and read-back data
  bit [31:0] source_memory[int];      // Stores data read from source address
  bit [31:0] destination_memory[int]; // Stores data read back from destination address

  bit [31:0] source_address;
  bit [31:0] destination_address;
  bit [31:0] num_byte;

  int  rd_queue [$];
  int total_bytes_read = 0;
  int total_bytes_written = 0;

  bit source_addr_checked = 0;
  bit dest_addr_checked = 0;
  bit transfer_check_done = 0;
  bit abort_flag = 0;

  uvm_analysis_imp_axil_csr_ap #(axi4lite_m_seq_item, dma_scoreboard) axil_csr_ap;
  uvm_analysis_imp_axi_transaction_ap #(axi4_s_seq_item, dma_scoreboard) axi_transaction_ap;

  function new(string name = "dma_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    axil_csr_ap = new("axil_csr_ap", this);
    axi_transaction_ap = new("axi_transaction_ap", this);
  endfunction

  function void write_axil_csr_ap(axi4lite_m_seq_item t);
    case (t.dma_s_awaddr)
      32'h00: begin
        if (t.dma_s_wdata[1]) begin
          abort_flag = 1;
          `uvm_warning("CSR", "?? ABORT received. Transfer verification will stop.");
        end
      end
      32'h20: source_address      = t.dma_s_wdata;
      32'h30: destination_address = t.dma_s_wdata;
      32'h40: num_byte            = t.dma_s_wdata;
    endcase
    `uvm_info("CSR", $sformatf("Set Source=0x%0h, Destination=0x%0h, NumByte=0x%0h", source_address, destination_address, num_byte), UVM_NONE)
  endfunction

  function void write_axi_transaction_ap(axi4_s_seq_item t);
		   int beat_size;
    if (abort_flag) begin
      `uvm_warning("axi4-scb", "Skipping AXI transaction due to ABORT flag.");
      return;
    end

   
    beat_size = 1 << 2; // 2^2 = 4 bytes (fixed data width)

    if (t.READ == 1) begin
      `uvm_info("axi4-scb", $sformatf("READ -> Addr: 0x%0h, Data: 0x%0h", t.dma_m_araddr, t.dma_m_rdata), UVM_NONE);
      rd_queue.push_front(t.dma_m_rdata);
      total_bytes_read += beat_size;

      if (!source_addr_checked) begin
        if (t.dma_m_araddr !== source_address) begin
          `uvm_warning("axi4-scb", $sformatf("Read from unexpected source address. Expected: 0x%0h, Got: 0x%0h", source_address, t.dma_m_araddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Source address match confirmed: 0x%0h", t.dma_m_araddr), UVM_NONE);
        end
        source_addr_checked = 1;
      end

    end else if (t.WRITE == 1) begin
      `uvm_info("axi4-scb", $sformatf("WRITE -> Addr: 0x%0h, Data: 0x%0h, WSTRB: %b", t.dma_m_awaddr, t.dma_m_wdata, t.dma_m_wstrb), UVM_NONE);
      total_bytes_written += beat_size;

      if (!dest_addr_checked) begin
        if (t.dma_m_awaddr !== destination_address) begin
          `uvm_warning("axi4-scb", $sformatf("Write to unexpected destination address. Expected: 0x%0h, Got: 0x%0h", destination_address, t.dma_m_awaddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Destination address match confirmed: 0x%0h", t.dma_m_awaddr), UVM_NONE);
        end
        dest_addr_checked = 1;
      end

      if (rd_queue.size() == 0) begin
        `uvm_error("axi4-scb", "Write occurred before corresponding read! Read queue is empty.");
      end else begin
        int expected = rd_queue.pop_back();

        for (int i = 0; i < 4; i++) begin
          if (t.dma_m_wstrb[i]) begin
            bit [7:0] expected_byte = expected >> (i * 8);
            bit [7:0] written_byte  = t.dma_m_wdata >> (i * 8);
            if (expected_byte !== written_byte) begin
              `uvm_error("axi4-scb", $sformatf("? Byte[%0d] Mismatch! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte));
            end else begin
              `uvm_info("axi4-scb", $sformatf("? Byte[%0d] Data Matched! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte), UVM_NONE);
            end
          end
        end

        `uvm_info("axi4-scb", "? Write data verification complete (WSTRB-based match)", UVM_NONE);
      end

      if (!transfer_check_done && total_bytes_read >= num_byte && total_bytes_written >= num_byte) begin
        if (total_bytes_read == num_byte && total_bytes_written == num_byte) begin
          `uvm_info("axi4-scb", $sformatf("? Total transfer matched! total_bytes_read = %0d, total_bytes_written = %0d, num_byte = %0d", total_bytes_read, total_bytes_written, num_byte), UVM_NONE);
        end else begin
          if (total_bytes_read != num_byte)
            `uvm_error("axi4-scb", $sformatf("? Total bytes READ (%0d) != Expected (%0d)", total_bytes_read, num_byte));
          if (total_bytes_written != num_byte)
            `uvm_error("axi4-scb", $sformatf("? Total bytes WRITTEN (%0d) != Expected (%0d)", total_bytes_written, num_byte));
        end
        transfer_check_done = 1;
      end

    end else begin
      `uvm_info("axi4-scb","Unknown transaction detected", UVM_NONE);
    end
  endfunction

  function void reset_queues();
    rd_queue.delete();
    source_address = 0;
    destination_address = 0;
    num_byte = 0;
    total_bytes_read = 0;
    total_bytes_written = 0;
    source_addr_checked = 0;
    dest_addr_checked = 0;
    transfer_check_done = 0;
    abort_flag = 0;
    `uvm_info("RESET", "Scoreboard state cleared.", UVM_LOW);
  endfunction
endclass
*/





//editable (planning to add done and num_byte queue)
/*
//add queue
`uvm_analysis_imp_decl(_axil_csr_ap)
`uvm_analysis_imp_decl(_axi_transaction_ap)

class dma_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dma_scoreboard)

  // Memory Models to track source data and read-back data
  bit [31:0] source_memory[int];      // Stores data read from source address
  bit [31:0] destination_memory[int]; // Stores data read back from destination address

  bit [31:0] source_address;
  bit [31:0] destination_address;
  bit [31:0] num_byte;

  int  rd_queue [$];
  int total_bytes_read = 0;
  int total_bytes_written = 0;

  bit source_addr_checked = 0;
  bit dest_addr_checked = 0;
  bit abort_flag = 0;

  uvm_analysis_imp_axil_csr_ap #(axi4lite_m_seq_item, dma_scoreboard) axil_csr_ap;
  uvm_analysis_imp_axi_transaction_ap #(axi4_s_seq_item, dma_scoreboard) axi_transaction_ap;

  function new(string name = "dma_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    axil_csr_ap = new("axil_csr_ap", this);
    axi_transaction_ap = new("axi_transaction_ap", this);
  endfunction

  function void write_axil_csr_ap(axi4lite_m_seq_item t);
    case (t.dma_s_awaddr)
      32'h00: begin
        if (t.dma_s_wdata[1]) begin
          abort_flag = 1;
          `uvm_warning("CSR", "?? ABORT received. Transfer verification will stop.");
        end
      end
      32'h20: source_address      = t.dma_s_wdata;
      32'h30: destination_address = t.dma_s_wdata;
	  32'h40: begin
	  
	  num_byte            = t.dma_s_wdata;

        // New config = new DMA session ? reset relevant flags/counters
        //source_addr_checked = 0;
        //dest_addr_checked   = 0;
        //total_bytes_read    = 0;
        //total_bytes_written = 0;
        //abort_flag          = 0;
      end
    endcase
    `uvm_info("CSR", $sformatf("Set Source=0x%0h, Destination=0x%0h, NumByte=0x%0h", source_address, destination_address, num_byte), UVM_NONE)
  endfunction

  function void write_axi_transaction_ap(axi4_s_seq_item t);
    int beat_size;
    if (abort_flag) begin
      `uvm_warning("axi4-scb", "Skipping AXI transaction due to ABORT flag.");
      return;
    end

    beat_size = 1 << 2; // 2^2 = 4 bytes (fixed data width)

    if (t.READ == 1) begin
      `uvm_info("axi4-scb", $sformatf("READ -> Addr: 0x%0h, Data: 0x%0h", t.dma_m_araddr, t.dma_m_rdata), UVM_NONE);
      rd_queue.push_front(t.dma_m_rdata);
      total_bytes_read += beat_size;
      `uvm_info("axi4-scb", $sformatf("total_bytes_read = %0d, num_byte = %0d", total_bytes_read, num_byte), UVM_NONE);
      
	  if (!source_addr_checked) begin
        if (t.dma_m_araddr !== source_address) begin
          `uvm_warning("axi4-scb", $sformatf("Read from unexpected source address. Expected: 0x%0h, Got: 0x%0h", source_address, t.dma_m_araddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Source address match confirmed: 0x%0h", t.dma_m_araddr), UVM_NONE);
        end
        source_addr_checked = 1;
      end

    end else if (t.WRITE == 1) begin
      `uvm_info("axi4-scb", $sformatf("WRITE -> Addr: 0x%0h, Data: 0x%0h, WSTRB: %b", t.dma_m_awaddr, t.dma_m_wdata, t.dma_m_wstrb), UVM_NONE);
      total_bytes_written += beat_size;
      `uvm_info("axi4-scb", $sformatf("total_bytes_written = %0d, num_byte = %0d", total_bytes_written, num_byte), UVM_NONE);

      if (!dest_addr_checked) begin
        if (t.dma_m_awaddr !== destination_address) begin
          `uvm_warning("axi4-scb", $sformatf("Write to unexpected destination address. Expected: 0x%0h, Got: 0x%0h", destination_address, t.dma_m_awaddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Destination address match confirmed: 0x%0h", t.dma_m_awaddr), UVM_NONE);
        end
        dest_addr_checked = 1;
      end

      if (rd_queue.size() == 0) begin
        `uvm_error("axi4-scb", "Write occurred before corresponding read! Read queue is empty.");
      end else begin
        int expected = rd_queue.pop_back();

        for (int i = 0; i < 4; i++) begin
          if (t.dma_m_wstrb[i]) begin
            bit [7:0] expected_byte = expected >> (i * 8);
            bit [7:0] written_byte  = t.dma_m_wdata >> (i * 8);
            if (expected_byte !== written_byte) begin
              `uvm_error("axi4-scb", $sformatf("? Byte[%0d] Mismatch! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte));
            end else begin
              `uvm_info("axi4-scb", $sformatf("? Byte[%0d] Data Matched! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte), UVM_NONE);
            end
          end
        end

        `uvm_info("axi4-scb", "? Write data verification complete (WSTRB-based match)", UVM_NONE);
      end

      // Num_byte match per DMA config
      if ((total_bytes_read >= num_byte) && (total_bytes_written >= num_byte)) begin
        if (total_bytes_read == num_byte && total_bytes_written == num_byte) begin
          `uvm_info("axi4-scb", $sformatf("? Total transfer matched! total_bytes_read = %0d, total_bytes_written = %0d, num_byte = %0d", total_bytes_read, total_bytes_written, num_byte), UVM_NONE);
        end else begin
          if (total_bytes_read != num_byte)
            `uvm_error("axi4-scb", $sformatf("? Total bytes READ (%0d) != Expected (%0d)", total_bytes_read, num_byte));
          if (total_bytes_written != num_byte)
            `uvm_error("axi4-scb", $sformatf("? Total bytes WRITTEN (%0d) != Expected (%0d)", total_bytes_written, num_byte));
        end

        // Prepare for next DMA session
        total_bytes_read    = 0;
        total_bytes_written = 0;
        source_addr_checked = 0;
        dest_addr_checked   = 0;
      end

    end else begin
      `uvm_info("axi4-scb","Unknown transaction detected", UVM_NONE);
    end
  endfunction

  function void reset_queues();
    rd_queue.delete();
    source_address = 0;
    destination_address = 0;
    num_byte = 0;
    total_bytes_read = 0;
    total_bytes_written = 0;
    source_addr_checked = 0;
    dest_addr_checked = 0;
    abort_flag = 0;
    `uvm_info("RESET", "Scoreboard state cleared.", UVM_LOW);
  endfunction
endclass
*/





//working (multiple sequence num_byte match fail, but single sequence match)
/*
`uvm_analysis_imp_decl(_axil_csr_ap)
`uvm_analysis_imp_decl(_axi_transaction_ap)

class dma_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dma_scoreboard)

  // Memory Models to track source data and read-back data
  bit [31:0] source_memory[int];      // Stores data read from source address
  bit [31:0] destination_memory[int]; // Stores data read back from destination address

  bit [31:0] source_address;
  bit [31:0] destination_address;
  bit [31:0] num_byte;

  int  rd_queue [$];
  int total_bytes_read = 0;
  int total_bytes_written = 0;

  bit source_addr_checked = 0;
  bit dest_addr_checked = 0;
  bit transfer_check_done = 0;
  bit abort_flag = 0;

  uvm_analysis_imp_axil_csr_ap #(axi4lite_m_seq_item, dma_scoreboard) axil_csr_ap;
  uvm_analysis_imp_axi_transaction_ap #(axi4_s_seq_item, dma_scoreboard) axi_transaction_ap;

  function new(string name = "dma_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    axil_csr_ap = new("axil_csr_ap", this);
    axi_transaction_ap = new("axi_transaction_ap", this);
  endfunction

  function void write_axil_csr_ap(axi4lite_m_seq_item t);
    case (t.dma_s_awaddr)
      32'h00: begin
        if (t.dma_s_wdata[1]) begin
          abort_flag = 1;
          `uvm_warning("CSR", "?? ABORT received. Transfer verification will stop.");
        end
      end
      32'h20: source_address      = t.dma_s_wdata;
      32'h30: destination_address = t.dma_s_wdata;
      32'h40: num_byte            = t.dma_s_wdata;
    endcase
    `uvm_info("CSR", $sformatf("Set Source=0x%0h, Destination=0x%0h, NumByte=0x%0h", source_address, destination_address, num_byte), UVM_NONE)
  endfunction

  function void write_axi_transaction_ap(axi4_s_seq_item t);
		   int beat_size;
    if (abort_flag) begin
      `uvm_warning("axi4-scb", "Skipping AXI transaction due to ABORT flag.");
      return;
    end

   
    beat_size = 1 << 2; // 2^2 = 4 bytes (fixed data width)

    if (t.READ == 1) begin
      `uvm_info("axi4-scb", $sformatf("READ -> Addr: 0x%0h, Data: 0x%0h", t.dma_m_araddr, t.dma_m_rdata), UVM_NONE);
      rd_queue.push_front(t.dma_m_rdata);
      total_bytes_read += beat_size;

      if (!source_addr_checked) begin
        if (t.dma_m_araddr !== source_address) begin
          `uvm_warning("axi4-scb", $sformatf("Read from unexpected source address. Expected: 0x%0h, Got: 0x%0h", source_address, t.dma_m_araddr));
        end else begin
`uvm_analysis_imp_decl(_axil_csr_ap)
`uvm_analysis_imp_decl(_axi_transaction_ap)

class dma_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dma_scoreboard)

  // Memory Models to track source data and read-back data
  bit [31:0] source_memory[int];      // Stores data read from source address
  bit [31:0] destination_memory[int]; // Stores data read back from destination address

  bit [31:0] source_address;
  bit [31:0] destination_address;
  bit [31:0] num_byte;

  int  rd_queue [$];
  int total_bytes_read = 0;
  int total_bytes_written = 0;

  bit source_addr_checked = 0;
  bit dest_addr_checked = 0;
  bit abort_flag = 0;

  uvm_analysis_imp_axil_csr_ap #(axi4lite_m_seq_item, dma_scoreboard) axil_csr_ap;
  uvm_analysis_imp_axi_transaction_ap #(axi4_s_seq_item, dma_scoreboard) axi_transaction_ap;

  function new(string name = "dma_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    axil_csr_ap = new("axil_csr_ap", this);
    axi_transaction_ap = new("axi_transaction_ap", this);
  endfunction

  function void write_axil_csr_ap(axi4lite_m_seq_item t);
    case (t.dma_s_awaddr)
      32'h00: begin
        if (t.dma_s_wdata[1]) begin
          abort_flag = 1;
          `uvm_warning("CSR", "?? ABORT received. Transfer verification will stop.");
        end
      end
      32'h20: source_address      = t.dma_s_wdata;
      32'h30: destination_address = t.dma_s_wdata;
      32'h40: num_byte            = t.dma_s_wdata;

        // New config = new DMA session ? reset relevant flags/counters
        source_addr_checked = 0;
        dest_addr_checked   = 0;
        total_bytes_read    = 0;
        total_bytes_written = 0;
        abort_flag          = 0;
    endcase
    `uvm_info("CSR", $sformatf("Set Source=0x%0h, Destination=0x%0h, NumByte=0x%0h", source_address, destination_address, num_byte), UVM_NONE)
  endfunction

  function void write_axi_transaction_ap(axi4_s_seq_item t);
    int beat_size;
    if (abort_flag) begin
      `uvm_warning("axi4-scb", "Skipping AXI transaction due to ABORT flag.");
      return;
    end

    beat_size = 1 << 2; // 2^2 = 4 bytes (fixed data width)

    if (t.READ == 1) begin
      `uvm_info("axi4-scb", $sformatf("READ -> Addr: 0x%0h, Data: 0x%0h", t.dma_m_araddr, t.dma_m_rdata), UVM_NONE);
      rd_queue.push_front(t.dma_m_rdata);
      total_bytes_read += beat_size;

      if (!source_addr_checked) begin
        if (t.dma_m_araddr !== source_address) begin
          `uvm_warning("axi4-scb", $sformatf("Read from unexpected source address. Expected: 0x%0h, Got: 0x%0h", source_address, t.dma_m_araddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Source address match confirmed: 0x%0h", t.dma_m_araddr), UVM_NONE);
        end
        source_addr_checked = 1;
      end

    end else if (t.WRITE == 1) begin
      `uvm_info("axi4-scb", $sformatf("WRITE -> Addr: 0x%0h, Data: 0x%0h, WSTRB: %b", t.dma_m_awaddr, t.dma_m_wdata, t.dma_m_wstrb), UVM_NONE);
      total_bytes_written += beat_size;

      if (!dest_addr_checked) begin
        if (t.dma_m_awaddr !== destination_address) begin
          `uvm_warning("axi4-scb", $sformatf("Write to unexpected destination address. Expected: 0x%0h, Got: 0x%0h", destination_address, t.dma_m_awaddr));
        end else begin
          `uvm_info("axi4-scb", $sformatf("? Destination address match confirmed: 0x%0h", t.dma_m_awaddr), UVM_NONE);
        end
        dest_addr_checked = 1;
      end

      if (rd_queue.size() == 0) begin
        `uvm_error("axi4-scb", "Write occurred before corresponding read! Read queue is empty.");
      end else begin
        int expected = rd_queue.pop_back();

        for (int i = 0; i < 4; i++) begin
          if (t.dma_m_wstrb[i]) begin
            bit [7:0] expected_byte = expected >> (i * 8);
            bit [7:0] written_byte  = t.dma_m_wdata >> (i * 8);
            if (expected_byte !== written_byte) begin
              `uvm_error("axi4-scb", $sformatf("? Byte[%0d] Mismatch! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte));
            end else begin
              `uvm_info("axi4-scb", $sformatf("? Byte[%0d] Data Matched! Expected: 0x%0h, Got: 0x%0h", i, expected_byte, written_byte), UVM_NONE);
            end
          end
        end

        `uvm_info("axi4-scb", "? Write data verification complete (WSTRB-based match)", UVM_NONE);
      end

      // Num_byte match per DMA config
      if ((total_bytes_read >= num_byte) && (total_bytes_written >= num_byte)) begin
        if (total_bytes_read == num_byte && total_bytes_written == num_byte) begin
          `uvm_info("axi4-scb", $sformatf("? Total transfer matched! total_bytes_read = %0d, total_bytes_written = %0d, num_byte = %0d", total_bytes_read, total_bytes_written, num_byte), UVM_NONE);
        end else begin
          if (total_bytes_read != num_byte)
            `uvm_error("axi4-scb", $sformatf("? Total bytes READ (%0d) != Expected (%0d)", total_bytes_read, num_byte));
          if (total_bytes_written != num_byte)
            `uvm_error("axi4-scb", $sformatf("? Total bytes WRITTEN (%0d) != Expected (%0d)", total_bytes_written, num_byte));
        end

        // Prepare for next DMA session
        total_bytes_read    = 0;
        total_bytes_written = 0;
        source_addr_checked = 0;
        dest_addr_checked   = 0;
      end

    end else begin
      `uvm_info("axi4-scb","Unknown transaction detected", UVM_NONE);
    end
  endfunction

  function void reset_queues();
    rd_queue.delete();
    source_address = 0;
    destination_address = 0;
    num_byte = 0;
    total_bytes_read = 0;
    total_bytes_written = 0;
    source_addr_checked = 0;
    dest_addr_checked = 0;
    abort_flag = 0;
    `uvm_info("RESET", "Scoreboard state cleared.", UVM_LOW);
  endfunction
endclass
*/ 




