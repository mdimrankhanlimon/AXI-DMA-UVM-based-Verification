
class axi4_s_coverage extends uvm_subscriber #(axi4_s_seq_item);
    `uvm_component_utils(axi4_s_coverage)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write(axi4_s_seq_item t);
        `uvm_info(get_name(), $sformatf("Received from Monitor"), UVM_NONE)
    endfunction

endclass