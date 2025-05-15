class csr_custom_test extends base_test;
  `uvm_component_utils(csr_custom_test)

  axi4lite_m_csr_wr_rd_custom_seq seq;

  // clock-reset sequence handles
  clock_enable    clk_enb[2];
  clock_disable   clk_dis;
  reset_enable    rst_enb;

  // Constructor
  function new(string name = "csr_custom_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_name(), "CSR Custom Test initiated", UVM_NONE);
    phase.phase_done.set_drain_time(this, 5000ns);
    
    phase.raise_objection(this);
      clk_enb[0] = clock_enable::type_id::create("clk_enb[0]");
      clk_enb[0].frequency = 500;
      clk_enb[0].clk_enb = 1;
      clk_enb[0].start(env.cr_agnt[0].sqncr);

      clk_enb[1] = clock_enable::type_id::create("clk_enb[1]");
      clk_enb[1].frequency = 500;
      clk_enb[1].clk_enb = 1;
      clk_enb[1].start(env.cr_agnt[1].sqncr);

      // Instantiate and start the custom CSR sequence.
      seq = axi4lite_m_csr_wr_rd_custom_seq::type_id::create("csr_custom_seq");
      seq.start(env.axi4lite_m_agnt.sqncr); // Removed "this" from the start() call.
    phase.drop_objection(this);
    
    `uvm_info(get_name(), "CSR Custom Test completed", UVM_LOW);
  endtask
endclass

