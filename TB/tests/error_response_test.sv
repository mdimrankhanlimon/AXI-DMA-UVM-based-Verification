class dma_error_response_test extends base_test;
  `uvm_component_utils(dma_error_response_test)

  axi4lite_m_error_injection_seq seq;

  // Clock-reset sequence handles
  clock_enable    clk_enb[2];
  clock_disable   clk_dis; // (Optional, if needed)
  reset_enable    rst_enb;

  // Constructor
  function new(string name = "dma_error_injection_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("TEST", "Applying override manually", UVM_NONE)

    uvm_factory::get().set_type_override_by_type(
    axi4_s_driver::get_type(),
    axi_s_error_driver::get_type()
  );
	endfunction

  virtual task run_phase(uvm_phase phase);
    // Hold the phase open for at least 40ns after test completion
    phase.phase_done.set_drain_time(this, 400ns);
    phase.raise_objection(this);
    `uvm_info(get_name(), "Starting DMA Error Injection Test", UVM_LOW);

    // Instantiate and start clock enable sequences for two channels
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

    // Create and run the error injection sequence using the environment's sequencer
    seq = axi4lite_m_error_injection_seq::type_id::create("error_injection_seq");
    seq.start(env.axi4lite_m_agnt.sqncr);

    phase.drop_objection(this);
    `uvm_info(get_name(), "DMA Error Injection Test Completed", UVM_LOW);
  endtask

endclass
