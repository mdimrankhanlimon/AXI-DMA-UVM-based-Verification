class axi4lite_m_agent_config extends uvm_object;
    `uvm_object_utils(axi4lite_m_agent_config)

    uvm_active_passive_enum is_active = UVM_PASSIVE;
    bit has_cover = 0;

	bit axi4lite_m_mntr_log;

    function new(string name = "axi4lite_m_agent_config");
        super.new(name);
    endfunction

endclass
