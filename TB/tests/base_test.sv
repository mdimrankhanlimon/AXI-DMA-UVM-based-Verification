
class base_test extends uvm_test;
	`uvm_component_utils(base_test)

	// Fields
	environment env;
	environment_config   env_cfg;

	clock_enable    clk_enb[2];
    clock_disable   clk_dis;
    reset_enable    rst_enb;

	uvm_factory factory = uvm_factory::get();

	// Constructor
	function new (string name = "base_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

    // environment configuration 
	virtual function void axi4lite_m_build_config (
		environment_config   env_cfg_hndl,
		uvm_active_passive_enum axi4_agent_activation = UVM_PASSIVE,
        uvm_active_passive_enum axi4lite_agent_activation = UVM_PASSIVE,
        bit axi4_agent_stat = 1,
        bit axi4lite_agent_stat = 1,
		bit axi4_agent_cover = 1,
        bit axi4lite_agent_cover = 1,
        bit axi4_s_mntr_log = 1,
        bit axi4lite_m_mntr_log = 1
	);

		env_cfg_hndl.axi4_agent_stat = axi4_agent_activation;
        env_cfg_hndl.axi4lite_agent_stat = axi4lite_agent_activation;

		env_cfg_hndl.axi4_agent_cover = axi4_agent_cover;
        env_cfg_hndl.axi4lite_agent_cover = axi4lite_agent_cover;
     
        env_cfg_hndl.axi4_s_mntr_log = axi4_s_mntr_log;
        env_cfg_hndl.axi4lite_m_mntr_log = axi4lite_m_mntr_log;
	endfunction

	//Phase
	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_name(), "build phase ", UVM_NONE)

		env_cfg = environment_config::type_id::create("env_cfg");

		axi4lite_m_build_config(env_cfg, UVM_ACTIVE, UVM_ACTIVE, 1, 1, 1, 1, 1, 1);
		env_cfg.has_scb = 1;

		uvm_config_db #(environment_config)::set(null, "*", "ENV_CFG",env_cfg);
		
		env = environment::type_id::create("env", this);

	endfunction

	function void end_of_elaboration_phase (uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		this.print();
		//factory = cs.get_factory();
		factory.print();
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		`uvm_info(get_name(), "Running Base Test", UVM_NONE)
	endtask

   virtual function void report_phase(uvm_phase phase);
   	uvm_report_server svr;
	super.report_phase(phase);

	svr = uvm_report_server::get_server();

	if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0 ) begin
		$display("---------------------------------------------------------------");
		$display("---------------    TEST FAIL    -------------------------------");
		$display("---------------------------------------------------------------");
	end else begin
		$display("---------------------------------------------------------------");
		$display("---------------    TEST PASS    -------------------------------");
		$display("---------------------------------------------------------------");
	end
   endfunction	

endclass
