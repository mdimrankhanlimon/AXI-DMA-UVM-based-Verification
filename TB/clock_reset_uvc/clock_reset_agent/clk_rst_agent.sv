
class clk_rst_agent extends uvm_agent;
	`uvm_component_utils (clk_rst_agent)

	clk_rst_agent_config 	agnt_cfg;
	clk_rst_driver 			drvr;
    uvm_sequencer #(clk_rst_seq_item) sqncr;

	function new (string name = "clk_rst_agent", uvm_component parent = null);
			super.new(name,parent);
	endfunction

	virtual function void build_phase (uvm_phase phase);
		sqncr = uvm_sequencer #(clk_rst_seq_item)::type_id::create("sqncr", this);
		drvr  = clk_rst_driver::type_id::create("drvr", this);
	endfunction

	virtual function void connect_phase (uvm_phase phase);
		drvr.seq_item_port.connect(sqncr.seq_item_export);
	endfunction
endclass

