class csr_wr_rd_test extends base_test;
  `uvm_component_utils(csr_wr_rd_test)

  axi4lite_m_csr_wr_rd_seq seq;

  // clock-reset sequence handle
  clock_enable    clk_enb[2];
  clock_disable   clk_dis;
  reset_enable    rst_enb;

  // Constructor
  function new(string name = "csr_wr_rd_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Optionally set a drain time for the phase
    `uvm_info(get_name(), "CSR Write-Read Test initiated", UVM_NONE);
    phase.phase_done.set_drain_time(this, 100ns);
    
    phase.raise_objection(this);
        clk_enb[0] = clock_enable::type_id::create("clk_enb[0]");
        clk_enb[0].frequency = 500;
        clk_enb[0].clk_enb = 1;
        clk_enb[0].start(env.cr_agnt[0].sqncr);

        clk_enb[1] = clock_enable::type_id::create("clk_enb[1]");
        clk_enb[1].frequency = 500;
        clk_enb[1].clk_enb = 1;
        clk_enb[1].start(env.cr_agnt[1].sqncr);

      // For this test, we'll run the CSR write-read sequence once
      seq = axi4lite_m_csr_wr_rd_seq::type_id::create("csr_wr_rd_seq");
      // Start the sequence using the environment's sequencer
      seq.start(env.axi4lite_m_agnt.sqncr);
    phase.drop_objection(this);
    
    `uvm_info(get_name(), "CSR Write-Read Test completed", UVM_LOW);
  endtask
endclass
