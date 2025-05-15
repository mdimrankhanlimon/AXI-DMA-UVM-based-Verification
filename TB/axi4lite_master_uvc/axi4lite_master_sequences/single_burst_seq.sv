class axi4lite_m_single_burst_seq extends axi4lite_m_base_seq;
    `uvm_object_utils(axi4lite_m_single_burst_seq)

    axi4lite_m_write_seq write_seq;
    axi4lite_m_reset_seq reset_seq;

    // Constructor
    function new(string name = "axi4lite_m_single_burst_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_name(), "Starting Single-Burst Transfer Sequence (Aligned, INCR Mode)", UVM_LOW);

            // reset sequence
        reset_seq = axi4lite_m_reset_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer,this);

        // Set common values: use non-secure protection
        prot  = 3'b010;
        strb  = 4'b1111;
        WRITE = 1;
        READ  = 0;

        // -----------------------------------------------
        // 1. Write Descriptor Source Address at offset 0x0000_0020
        addr = 32'h0000_0020;
        data = 32'h0000_0000; // Source address
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq_src");
        write_seq.WRITE = 1;
        write_seq.addr  = addr;
        write_seq.data  = data;
        write_seq.prot  = prot;
        write_seq.strb  = strb;
        write_seq.start(m_sequencer, this);

        // -----------------------------------------------
        // 2. Write Descriptor Destination Address at offset 0x0000_0030
        addr = 32'h0000_0030;
        data = 32'h0000_0400; // Destination address
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq_dst");
        write_seq.WRITE = 1;
        write_seq.addr  = addr;
        write_seq.data  = data;
        write_seq.prot  = prot;
        write_seq.strb  = strb;
        write_seq.start(m_sequencer, this);

        // -----------------------------------------------
        // 3. Write Descriptor Number of Bytes at offset 0x0000_0040
        addr = 32'h0000_0040;
        data = 32'h0000_0020; // 32 bytes (0x20)
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq_len");
        write_seq.WRITE = 1;
        write_seq.addr  = addr;
        write_seq.data  = data;
        write_seq.prot  = prot;
        write_seq.strb  = strb;
        write_seq.start(m_sequencer, this);

        // -----------------------------------------------
        // 4. Write Descriptor Configuration at offset 0x0000_0050
        addr = 32'h0000_0050;
        data = 32'h0000_0004; // Configuration: INCR mode and enable descriptor
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq_cfg");
        write_seq.WRITE = 1;
        write_seq.addr  = addr;
        write_seq.data  = data;
        write_seq.prot  = prot;
        write_seq.strb  = strb;
        write_seq.start(m_sequencer, this);

        // -----------------------------------------------
        // Final: Configure the DMA Control Register at offset 0x0000_0000
        // with the data 0x00000021.
        addr = 32'h0000_0000;
        data = 32'h0000_0005;
        write_seq = axi4lite_m_write_seq::type_id::create("write_seq_ctrl_final");
        write_seq.WRITE = 1;
        write_seq.addr  = addr;
        write_seq.data  = data;
        write_seq.prot  = prot;
        write_seq.strb  = strb;
        write_seq.start(m_sequencer, this);

        `uvm_info(get_name(), "Single-Burst Transfer Sequence Completed. DMA transfer initiated.", UVM_LOW);
    endtask

endclass

