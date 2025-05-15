class unaligned_transfer_seq extends axi4lite_m_base_seq;
		`uvm_object_utils(unaligned_transfer_seq)
		
		// handle declare
		axi4lite_m_write_seq write_seq;
  		axi4lite_m_reset_seq reset_seq;
		
		// constructor function
		function new(string name="unaligned_transfer_seq");
				super.new(name);
		endfunction

		// Body task
		`uvm_info(get_name(),"Starting the sequence",UVM_LOW);

		// reset sequence
		reset_seq =axi4lite_m_reset_seq :: type_id ::create("reset_seq");
		reset_seq.start(m_sequencer,this);

		// protection and common signal
		prot = 3'b010;   	//[prot[0]-priviliged access, prot[1]-non-secure transaction, prot[2]-data/instruction access]
		strb = 4'b1111; 	// Full byte write enable
		WRITE = 1;

		// -----------------------------------
		// write DMA Descriptor source address for descriptor 0(offset 0x20)
		
		
		


endclass

