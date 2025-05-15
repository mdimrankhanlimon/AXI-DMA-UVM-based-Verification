class dma_burst_exceeds_4k_boundary_test extends base_test;
  `uvm_component_utils(dma_burst_exceeds_4k_boundary_test)

  axi4lite_m_boundary_seq boundary_seq;

  // Clock-reset sequence handles
  clock_enable    clk_enb[2];
  clock_disable   clk_dis; // if needed
  reset_enable    rst_enb;

  // Constructor
  function new(string name = "dma_burst_exceeds_4k_boundary_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Set drain time to hold the phase for at least 40ns after test completion
    phase.phase_done.set_drain_time(this,400ns);
    phase.raise_objection(this);
    `uvm_info(get_name(), "Starting DMA 4kb Boundary Test", UVM_LOW);

    // Instantiate and start clock enable sequences on two channels
    clk_enb[0] = clock_enable::type_id::create("clk_enb[0]");
    clk_enb[0].frequency = 100;
    clk_enb[0].clk_enb   = 1;
    clk_enb[0].start(env.cr_agnt[0].sqncr);

    clk_enb[1] = clock_enable::type_id::create("clk_enb[1]");
    clk_enb[1].frequency = 100;
    clk_enb[1].clk_enb   = 1;
    clk_enb[1].start(env.cr_agnt[1].sqncr);

    // Instantiate and start the reset enable sequence
    rst_enb = reset_enable::type_id::create("rst_enb");
    rst_enb.start(env.cr_agnt[0].sqncr);

    // Create and run the boundary sequence using the environment's sequencer
    boundary_seq = axi4lite_m_boundary_seq::type_id::create("boundary_seq");
    boundary_seq.start(env.axi4lite_m_agnt.sqncr);

    phase.drop_objection(this);
    `uvm_info(get_name(), "DMA 4kb Boundary Test Completed", UVM_LOW);
  endtask

endclass

