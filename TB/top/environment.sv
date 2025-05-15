
class environment extends uvm_env;
    `uvm_component_utils(environment)

    dma_scoreboard              scb;
	dma_cvrg_sb                 cvrg;

    environment_config          env_cfg;

    clk_rst_agent_config        clk_rst_agnt_cfg;
    clk_rst_agent               clk_rst_agnt;
        
    axi4_s_agent_config         axi4_s_agnt_cfg;
    axi4_s_agent                axi4_s_agnt;

    axi4lite_m_agent_config     axi4lite_m_agnt_cfg;
    axi4lite_m_agent            axi4lite_m_agnt;

    // clock reaet agent
    clk_rst_agent cr_agnt[2];

    function new (string name = "environment", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
            if (! uvm_config_db #(environment_config)::get(this, "*", "ENV_CFG", env_cfg) )
                    `uvm_fatal(get_name(), "Could not get env configuration from environment class")

            axi4_s_agnt_cfg = axi4_s_agent_config::type_id::create("axi4_s_agnt_cfg");
            axi4_s_agnt_cfg.is_active = env_cfg.axi4_agent_stat;
            axi4_s_agnt_cfg.has_cover = env_cfg.axi4_agent_cover;
            axi4_s_agnt_cfg.axi4_s_mntr_log = env_cfg.axi4_s_mntr_log;
            
            uvm_config_db #(axi4_s_agent_config)::set(null, "*", "AXI4_S_AGNT_CFG", axi4_s_agnt_cfg);

            axi4_s_agnt = axi4_s_agent::type_id::create("axi4_s_agnt", this);

            axi4lite_m_agnt_cfg = axi4lite_m_agent_config::type_id::create("axi4_s_agnt_cfg");
            axi4lite_m_agnt_cfg.is_active = env_cfg.axi4lite_agent_stat;
            axi4lite_m_agnt_cfg.has_cover = env_cfg.axi4lite_agent_cover;
            axi4lite_m_agnt_cfg.axi4lite_m_mntr_log = env_cfg.axi4lite_m_mntr_log;
            
            uvm_config_db #(axi4lite_m_agent_config)::set(null, "*", "AXI4LITE_M_AGNT_CFG", axi4lite_m_agnt_cfg);

            axi4lite_m_agnt = axi4lite_m_agent::type_id::create("axi4lite_m_agnt", this);
            cvrg = dma_cvrg_sb::type_id::create("cvrg", this);

            if (env_cfg.has_scb) begin
                scb = dma_scoreboard::type_id::create("scb", this);
            end

            cr_agnt[0] = clk_rst_agent::type_id::create("cr_agnt[0]", this);
            cr_agnt[1] = clk_rst_agent::type_id::create("cr_agnt[1]", this);
            
            uvm_config_db#(clock_select_t)::set(this, "cr_agnt[0].*", "CLOCK_SELECT", clk);
            uvm_config_db#(reset_select_t)::set(this, "cr_agnt[0].*", "RESET_SELECT", rst_n);

            uvm_config_db#(clock_select_t)::set(this, "cr_agnt[1].*", "CLOCK_SELECT", CLK_1);
            uvm_config_db#(reset_select_t)::set(this, "cr_agnt[1].*", "RESET_SELECT", RESET_1);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        if (env_cfg.has_scb) begin
            axi4_s_agnt.axi4_s_agnt_port.connect(scb.axi_transaction_ap);
            axi4lite_m_agnt.axi4lite_m_agnt_port.connect(scb.axil_csr_ap);              
        end
		axi4lite_m_agnt.axi4lite_m_mntr.ap.connect(cvrg.axi4l_trx_port);
		axi4_s_agnt.axi4_s_mntr.axi4_s_mntr_port.connect(cvrg.axi4_trx_port);
		
    endfunction

endclass

