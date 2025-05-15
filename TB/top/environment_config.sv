
class environment_config extends uvm_object;
    `uvm_object_utils (environment_config)

    uvm_active_passive_enum axi4_agent_stat = UVM_PASSIVE;
    uvm_active_passive_enum axi4lite_agent_stat = UVM_PASSIVE;

    bit axi4_agent_cover = 0;
    bit axi4lite_agent_cover = 0;

    bit has_scb = 0;

    bit axi4_s_mntr_log, axi4lite_m_mntr_log;

    function new (string name = "environment_config");
            super.new(name);
    endfunction

endclass
