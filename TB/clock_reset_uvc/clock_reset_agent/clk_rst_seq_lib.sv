class base_seq extends uvm_sequence #(clk_rst_seq_item);
		//Factory registration
		`uvm_object_utils (base_seq)

		int reset;
		int frequency;
		int clk_enb;

		//Constructor
		function new (string name = "base_seq");
				super.new(name);
		endfunction

		// body task
		virtual task body();
			`uvm_info (get_name(), $sformatf("Running Base sequence From base Seq"), UVM_HIGH);
		endtask

endclass


class clock_enable extends base_seq;
	`uvm_object_utils (clock_enable)
	
	//Constructor
	function new (string name = "clock_enable");
			super.new(name);
	endfunction

	// body task
	virtual task body();
		`uvm_info (get_full_name(), $sformatf("Running %s sequence", get_name()), UVM_NONE)
		req = clk_rst_seq_item::type_id::create("req");
		start_item(req);
		  req.reset 	= reset;
		  req.frequency = frequency;
		  req.clk_enb	= clk_enb;
		  req.clk_ctrl	= 1;
		finish_item(req);
		req.print();
	endtask

endclass

class clock_disable extends base_seq;
	`uvm_object_utils (clock_disable)
	
	//Constructor
	function new (string name = "clock_disable");
			super.new(name);
	endfunction

	// body task
	virtual task body();
		`uvm_info (get_full_name(), $sformatf("Running %s sequence", get_name()), UVM_NONE)
		req = clk_rst_seq_item::type_id::create("req");
		start_item(req);
		  req.frequency = frequency;
		  req.clk_enb	= clk_enb;
		  req.clk_ctrl	= 1;
		finish_item(req);
		req.print();
	endtask

endclass


class reset_enable extends base_seq;
	`uvm_object_utils (reset_enable)
	
	//Constructor
	function new (string name = "reset_enable");
			super.new(name);
	endfunction

	// body task
	virtual task body();
		`uvm_info (get_full_name(), $sformatf("Running %s sequence", get_name()), UVM_NONE)
		req = clk_rst_seq_item::type_id::create("req");
		start_item(req);
		  req.reset 	= reset;
		  req.clk_ctrl	= 0;
		finish_item(req);
		req.print();
	endtask

endclass

