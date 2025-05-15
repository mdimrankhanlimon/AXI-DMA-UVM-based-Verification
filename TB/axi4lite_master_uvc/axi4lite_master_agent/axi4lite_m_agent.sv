
class axi4lite_m_agent extends uvm_agent;
    `uvm_component_utils (axi4lite_m_agent)

    axi4lite_m_agent_config 	axi4lite_m_agnt_cfg;
    axi4lite_m_driver  		    axi4lite_m_drvr;
    axi4lite_monitor 		    axi4lite_m_mntr;
    //axi4lite_m_coverage 		axi4lite_m_cov;

    uvm_sequencer #(axi4lite_m_seq_item) sqncr;

    uvm_analysis_port #(axi4lite_m_seq_item) axi4lite_m_agnt_port;

    function new (string name = "axi4lite_m_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        if (! uvm_config_db #(axi4lite_m_agent_config)::get(this, "*", "AXI4LITE_M_AGNT_CFG", axi4lite_m_agnt_cfg) )
            `uvm_fatal(get_name(), "Could not get agent configuration from axi4lite_m_agent class")

        if (axi4lite_m_agnt_cfg.is_active == UVM_ACTIVE) begin
            axi4lite_m_drvr = axi4lite_m_driver::type_id::create("axi4lite_m_drvr", this);
            sqncr = uvm_sequencer #(axi4lite_m_seq_item) ::type_id::create("sqncr", this);
        end
        `uvm_info(get_type_name(), "Before coverage Instace creating from Agent", UVM_NONE)
        if (axi4lite_m_agnt_cfg.has_cover) begin
            `uvm_info(get_type_name(), "Coverage Instace creating from Agent", UVM_NONE)
            //axi4lite_m_cov = axi4lite_m_coverage::type_id::create("axi4lite_m_cov", this);
        end

        axi4lite_m_mntr = axi4lite_monitor::type_id::create("axi4lite_m_mntr", this);

        axi4lite_m_agnt_port = new("axi4lite_m_agnt_port", this);

        axi4lite_m_mntr.axi4lite_m_mntr_log = axi4lite_m_agnt_cfg.axi4lite_m_mntr_log;
        `uvm_info(get_name(), $sformatf("value of mntr_log: %0d", axi4lite_m_mntr.axi4lite_m_mntr_log), UVM_NONE);

    endfunction

    virtual function void connect_phase (uvm_phase phase);
        
        if (axi4lite_m_agnt_cfg.is_active == UVM_ACTIVE) begin
            axi4lite_m_drvr.seq_item_port.connect(sqncr.seq_item_export);
        end
        
        axi4lite_m_mntr.ap.connect(axi4lite_m_agnt_port);
        /*
        if (axi4lite_m_agnt_cfg.has_cover) begin
            axi4lite_m_mntr.ap.connect(axi4lite_m_cov.analysis_export);
        end		
        */
    endfunction

endclass
