
class sanity_simple_seq extends uvm_sequence;
		`uvm_object_utils(sanity_simple_seq)

		clock_enable 	clk_enb;
		clock_disable 	clk_dis;
		reset_enable 	rst_enb;

		function new(string name = "sanity_simple_seq");
			super.new(name);
		endfunction

		virtual task body();
			`uvm_info (get_name(), $sformatf("Start  >>>  %s", get_type_name()), UVM_NONE)

			clk_enb = clock_enable::type_id::create("clk_enb");
			clk_enb.start(m_sequencer, this);

			#10;

			clk_dis = clock_disable::type_id::create("clk_dis");
			clk_dis.start(m_sequencer,this);

			#10;

			rst_enb = reset_enable::type_id::create("rst_enb");
			rst_enb.start(m_sequencer,this);

			#10;

			`uvm_info (get_name(), $sformatf("END  >>>  %s", get_type_name()), UVM_NONE)
		endtask

endclass

