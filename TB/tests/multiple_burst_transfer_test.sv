class multiple_burst_transfer_test extends base_test;
  `uvm_component_utils(multiple_burst_transfer_test)

  axi4lite_m_multiple_burst_seq seq;

  // Clock-reset sequence handles
  clock_enable    clk_enb[2];
  reset_enable    rst_enb;

  // Constructor
  function new(string name = "multiple_burst_transfer_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Hold the phase open for at least 40 ns after test completion
    phase.phase_done.set_drain_time(this, 40ns);
    phase.raise_objection(this);
    `uvm_info(get_name(), "Starting Multiple-Burst Transfer Test", UVM_LOW);

    // Instantiate and start clock enable sequences for two channels
    clk_enb[0] = clock_enable::type_id::create("clk_enb[0]");
    clk_enb[0].frequency = 100;  // Set desired frequency
    clk_enb[0].clk_enb   = 1;
    clk_enb[0].start(env.cr_agnt[0].sqncr);

    clk_enb[1] = clock_enable::type_id::create("clk_enb[1]");
    clk_enb[1].frequency = 100;  // Set desired frequency
    clk_enb[1].clk_enb   = 1;
    clk_enb[1].start(env.cr_agnt[1].sqncr);

    // Instantiate and start the reset enable sequence
    rst_enb = reset_enable::type_id::create("rst_enb");
    rst_enb.start(env.cr_agnt[0].sqncr);

    // Create and start the single burst sequence using the environment's sequencer
    seq = axi4lite_m_multiple_burst_seq::type_id::create("seq");
    seq.start(env.axi4lite_m_agnt.sqncr);

    phase.drop_objection(this);
    `uvm_info(get_name(), "Multiple-Burst Transfer Test Completed", UVM_LOW);
  endtask

endclass

