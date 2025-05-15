
class axi4_s_agent extends uvm_agent;
    `uvm_component_utils (axi4_s_agent)

    axi4_s_agent_config 	axi4_s_agnt_cfg;
    axi4_s_driver  		    axi4_s_drvr;
    axi4_s_monitor 		    axi4_s_mntr;
    //axi4_s_coverage 		axi4_s_cov;

    uvm_sequencer #(axi4_s_seq_item) sqncr;

    uvm_analysis_port #(axi4_s_seq_item) axi4_s_agnt_port;

    function new (string name = "axi4_s_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        if (! uvm_config_db #(axi4_s_agent_config)::get(this, "*", "AXI4_S_AGNT_CFG", axi4_s_agnt_cfg) )
            `uvm_fatal(get_name(), "Could not get agent configuration from axi4_s_agent class")

        if (axi4_s_agnt_cfg.is_active == UVM_ACTIVE) begin
            axi4_s_drvr = axi4_s_driver::type_id::create("axi4_s_drvr", this);
            sqncr = uvm_sequencer #(axi4_s_seq_item) ::type_id::create("sqncr", this);
        end
        `uvm_info(get_type_name(), "Before coverage Instace creating from Agent", UVM_NONE)
        if (axi4_s_agnt_cfg.has_cover) begin
            `uvm_info(get_type_name(), "Coverage Instace creating from Agent", UVM_NONE)
            //axi4_s_cov = axi4_s_coverage::type_id::create("axi4_s_cov", this);
        end

        axi4_s_mntr = axi4_s_monitor::type_id::create("axi4_s_mntr", this);

        axi4_s_agnt_port = new("axi4_s_agnt_port", this);

        axi4_s_mntr.axi4_s_mntr_log = axi4_s_agnt_cfg.axi4_s_mntr_log;
        `uvm_info(get_name(), $sformatf("value of mntr_log: %0d", axi4_s_mntr.axi4_s_mntr_log), UVM_NONE);

    endfunction

    virtual function void connect_phase (uvm_phase phase);

        axi4_s_mntr.axi4_s_mntr_port.connect(axi4_s_agnt_port);
        /*
        if (axi4_s_agnt_cfg.is_active == UVM_ACTIVE) begin
            axi4_s_drvr.seq_item_port.connect(sqncr.seq_item_export);
        end

        if (axi4_s_agnt_cfg.has_cover) begin
            axi4_s_mntr.axi4_s_mntr_port.connect(axi4_s_cov.analysis_export);
        end		
        */
    endfunction

endclass
