class dma_disabled_descriptor_test extends base_test;
  `uvm_component_utils(dma_disabled_descriptor_test)

  axi4lite_m_disabled_descriptor_seq seq;

  // Clock-reset sequence handles
  clock_enable    clk_enb[2];
  clock_disable   clk_dis;  // (Optional, if needed)
  reset_enable    rst_enb;

  // Constructor
  function new(string name = "dma_disabled_descriptor_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Hold the phase for at least 40 ns after test completion
    phase.phase_done.set_drain_time(this, 40ns);
    phase.raise_objection(this);
    `uvm_info(get_name(), "Starting DMA Disabled Descriptor Test", UVM_LOW);

    // Instantiate and start clock enable sequences on two channels
    clk_enb[0] = clock_enable::type_id::create("clk_enb[0]");
    clk_enb[0].frequency = 100; // Set the desired frequency
    clk_enb[0].clk_enb   = 1;
    clk_enb[0].start(env.cr_agnt[0].sqncr);

    clk_enb[1] = clock_enable::type_id::create("clk_enb[1]");
    clk_enb[1].frequency = 100; // Set the desired frequency
    clk_enb[1].clk_enb   = 1;
    clk_enb[1].start(env.cr_agnt[1].sqncr);

    // Instantiate and start the reset enable sequence
    rst_enb = reset_enable::type_id::create("rst_enb");
    rst_enb.start(env.cr_agnt[0].sqncr);

    // Create and run the disabled descriptor sequence using the environment's sequencer
    seq = axi4lite_m_disabled_descriptor_seq::type_id::create("disabled_descriptor_seq");
    seq.start(env.axi4lite_m_agnt.sqncr);

    phase.drop_objection(this);
    `uvm_info(get_name(), "DMA Disabled Descriptor Test Completed", UVM_LOW);
  endtask

endclass

