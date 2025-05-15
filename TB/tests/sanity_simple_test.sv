class sanity_simple_test extends base_test;
  `uvm_component_utils(sanity_simple_test)

  sanity_simple_sequence seq;

  // Clock-reset sequence handles
  clock_enable    clk_enb[2];
  clock_disable   clk_dis;
  reset_enable    rst_enb;

  // Constructor
  function new(string name = "sanity_simple_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_name(), "Sanity Simple Test initiated", UVM_NONE);
    phase.phase_done.set_drain_time(this, 400ns);
    
    phase.raise_objection(this);

      // Instantiate and start clock enable sequences
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

      // Instantiate and start the sanity simple sequence using the environment's sequencer
      seq = sanity_simple_sequence::type_id::create("sanity_simple_seq");
      seq.start(env.axi4lite_m_agnt.sqncr);

    phase.drop_objection(this);
    
    `uvm_info(get_name(), "Sanity Simple Test completed", UVM_LOW);
  endtask
endclass
