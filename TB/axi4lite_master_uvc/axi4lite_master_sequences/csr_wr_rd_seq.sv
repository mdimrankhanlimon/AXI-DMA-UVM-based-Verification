class axi4lite_m_csr_wr_rd_seq extends axi4lite_m_base_seq;
    `uvm_object_utils(axi4lite_m_csr_wr_rd_seq)

    axi4lite_m_write_seq write_seq;
    axi4lite_m_read_seq read_seq;
    axi4lite_m_reset_seq reset_seq;

    function new(string name = "axi4lite_m_csr_wr_rd_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_name(), "Starting CSR Write-Read Sequence", UVM_LOW);

        // reset sequence
        reset_seq = axi4lite_m_reset_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer,this);

        // Define protection and common signals
        prot = 3'b010; //  non-secure (AXI_NONSECURE)
        strb = 4'b1111; // Full byte write enable

        // -----------------------------------------------
        // **Read from All CSR Registers**
        // -----------------------------------------------

        // Read DMA Control Register at offset 0x00
        addr = 32'h0000_0000;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        addr = 32'h0000_0008;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        addr = 32'h0000_0010;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        addr = 32'h0000_0018;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor Source Address at offset 0x20
        addr = 32'h0000_0020;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
        read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor Destination Address at offset 0x30
        addr = 32'h0000_0030;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor Number of Bytes at offset 0x40
        addr = 32'h0000_0040;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor Configuration at offset 0x50
        addr = 32'h0000_0050;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
        read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);
    
	   // Read DMA Descriptor1 Source Address at offset 0x28
        addr = 32'h0000_0028;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
        read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor1 Destination Address at offset 0x38
        addr = 32'h0000_0038;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor1 Number of Bytes at offset 0x48
        addr = 32'h0000_0048;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor1 Configuration at offset 0x58
        addr = 32'h0000_0058;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
        read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);


        #20;
        // -----------------------------------------------
        // **Write to All CSR Registers**
        // -----------------------------------------------

        // Write DMA Descriptor Source Address at offset 0x20
        addr = 32'h0000_0020;
        data = 32'h0000_0000;
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
		write_seq.WRITE=1;
		write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

        // Write DMA Descriptor Destination Address at offset 0x30
        addr = 32'h0000_0030;
        data = 32'h0000_1400;
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");	
		write_seq.WRITE=1;
        write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

        // Write DMA Descriptor Number of Bytes at offset 0x40
        addr = 32'h0000_0040;
        data = 32'h0000_0048; // 4 bytes (0x100)
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
		write_seq.WRITE=1;
        write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

        // Write DMA Descriptor Configuration at offset 0x50
        addr = 32'h0000_0050;
        data = 32'h0000_0004; // Example configuration
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
		write_seq.WRITE=1;
		write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

		// Write DMA Descriptor1 Source Address at offset 0x28
        addr = 32'h0000_0028;
        data = 32'h0000_0004;
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
		write_seq.WRITE=1;
		write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

        // Write DMA Descriptor1 Destination Address at offset 0x38
        addr = 32'h0000_0038;
        data = 32'h0000_1404;
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");	
		write_seq.WRITE=1;
        write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

        // Write DMA Descriptor1 Number of Bytes at offset 0x48
        addr = 32'h0000_0048;
        data = 32'h0000_0024; // 4 bytes (0x100)
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
		write_seq.WRITE=1;
        write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

        // Write DMA Descriptor1 Configuration at offset 0x58
        addr = 32'h0000_0058;
        data = 32'h0000_0004; // Example configuration
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
		write_seq.WRITE=1;
		write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

        // Write DMA Control Configuration at offset 0x00
        addr = 32'h0000_0000;
        data = 32'h0000_0021; // Example configuration
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq");
		write_seq.WRITE=1;
		write_seq.addr = addr;
        write_seq.data = data;
        write_seq.prot = prot;
        write_seq.strb = strb;
        write_seq.start(m_sequencer,this);

        // Small delay before reading back values
        #200;

        // -----------------------------------------------
        // **Read from All CSR Registers**
        // -----------------------------------------------
 // Read DMA Control Register at offset 0x00
        addr = 32'h0000_0000;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        addr = 32'h0000_0008;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        addr = 32'h0000_0010;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        addr = 32'h0000_0018;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor Source Address at offset 0x20
        addr = 32'h0000_0020;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
        read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor Destination Address at offset 0x30
        addr = 32'h0000_0030;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor Number of Bytes at offset 0x40
        addr = 32'h0000_0040;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor Configuration at offset 0x50
        addr = 32'h0000_0050;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
        read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);
    
	   // Read DMA Descriptor1 Source Address at offset 0x28
        addr = 32'h0000_0028;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
        read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor1 Destination Address at offset 0x38
        addr = 32'h0000_0038;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor1 Number of Bytes at offset 0x48
        addr = 32'h0000_0048;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
        read_seq.READ=1;
		read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        // Read DMA Descriptor1 Configuration at offset 0x58
        addr = 32'h0000_0058;
        read_seq = axi4lite_m_read_seq::type_id::create("read_seq");
		read_seq.READ=1;
        read_seq.addr = addr;
        read_seq.prot = prot;
        read_seq.start(m_sequencer,this);

        `uvm_info(get_name(), "CSR Write-Read Sequence Completed", UVM_LOW);
    endtask
endclass

