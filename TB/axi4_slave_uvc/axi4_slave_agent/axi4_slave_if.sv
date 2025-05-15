interface axi4_slave_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32, ID_WIDTH = 4) ();
  
    bit CLK_1;
    bit RESET_1;

    // Write Address Channel (AW)
    logic [ADDR_WIDTH-1:0] dma_m_awaddr;  // Write address
    logic [ID_WIDTH-1:0] dma_m_awid;      // Write transaction ID
    logic [7:0] dma_m_awlen;              // Burst length
    logic [2:0] dma_m_awsize;             // Burst size
    logic [1:0] dma_m_awburst;            // Burst type
    logic dma_m_awlock;                   // Lock type
    logic [3:0] dma_m_awcache;            // Cache type
    logic [2:0] dma_m_awprot;             // Protection type
    logic [3:0] dma_m_awqos;              // Quality of service
    logic [3:0] dma_m_awregion;           // Region
    logic [3:0] dma_m_awuser;             // User-defined signals
    logic dma_m_awvalid;                  // Write address valid
    logic dma_m_awready;                  // Write address ready

    // Write Data Channel (W)
    logic [DATA_WIDTH-1:0] dma_m_wdata;   // Write data
    logic [DATA_WIDTH/8-1:0] dma_m_wstrb; // Write strobes
    logic dma_m_wlast;                    // Write last (end of burst)
    logic dma_m_wvalid;                   // Write valid
    logic dma_m_wready;                   // Write ready
    logic [3:0] dma_m_wuser;              // Write user data

    // Write Response Channel (B)
    logic dma_m_bready;                   // Write response ready
    logic [ID_WIDTH-1:0] dma_m_bid;       // Write transaction ID
    logic [1:0] dma_m_bresp;              // Write response
    logic [3:0] dma_m_buser;              // Write user response
    logic dma_m_bvalid;                   // Write response valid

    // Read Address Channel (AR)
    logic [ADDR_WIDTH-1:0] dma_m_araddr;  // Read address
    logic [ID_WIDTH-1:0] dma_m_arid;      // Read transaction ID
    logic [7:0] dma_m_arlen;              // Burst length
    logic [2:0] dma_m_arsize;             // Burst size
    logic [1:0] dma_m_arburst;            // Burst type
    logic dma_m_arlock;                   // Lock type
    logic [3:0] dma_m_arcache;            // Cache type
    logic [2:0] dma_m_arprot;             // Protection type
    logic [3:0] dma_m_arqos;              // Quality of service
    logic [3:0] dma_m_arregion;           // Region
    logic [3:0] dma_m_aruser;             // User-defined signals
    logic dma_m_arvalid;                  // Read address valid
    logic dma_m_arready;                  // Read address ready

    // Read Data Channel (R)
    logic [DATA_WIDTH-1:0] dma_m_rdata;   // Read data
    logic [ID_WIDTH-1:0] dma_m_rid;       // Read transaction ID
    logic [1:0] dma_m_rresp;              // Read response
    logic dma_m_rlast;                    // Read last (end of burst)
    logic dma_m_rvalid;                   // Read valid
    logic dma_m_rready;                   // Read ready
    logic [3:0] dma_m_ruser;              // Read user data

    /*
    // Modport for AXI Master
    modport slave (output dma_m_awaddr, dma_m_awid, dma_m_awlen, dma_m_awsize, dma_m_awburst, 
                    output dma_m_awlock, dma_m_awcache, dma_m_awprot, dma_m_awqos, dma_m_awregion,
                    output dma_m_awuser, dma_m_awvalid, dma_m_awready,
                    output dma_m_wdata, dma_m_wstrb, dma_m_wlast, dma_m_wvalid, dma_m_wready,
                    output dma_m_wuser,
                    input dma_m_bresp, dma_m_bvalid, 
                    output dma_m_bready, dma_m_bid, dma_m_buser,
                    output dma_m_araddr, dma_m_arid, dma_m_arlen, dma_m_arsize, dma_m_arburst, 
                    output dma_m_arlock, dma_m_arcache, dma_m_arprot, dma_m_arqos, dma_m_arregion,
                    output dma_m_aruser, dma_m_arvalid, dma_m_arready,
                    input dma_m_rdata, dma_m_rid, dma_m_rresp, dma_m_rlast, dma_m_rvalid, dma_m_rready,
                    input dma_m_ruser);

    // Clocking block for AXI Master
    clocking slave_cb @(posedge CLK_1);
        input dma_m_awaddr, dma_m_awid, dma_m_awlen, dma_m_awsize, dma_m_awburst;
        input dma_m_awlock, dma_m_awcache, dma_m_awprot, dma_m_awqos, dma_m_awregion;
        input dma_m_awuser, dma_m_awvalid, dma_m_awready;
        input dma_m_wdata, dma_m_wstrb, dma_m_wlast, dma_m_wvalid, dma_m_wready;
        input dma_m_wuser;
        output dma_m_bresp, dma_m_bvalid;
        output dma_m_bready, dma_m_bid, dma_m_buser;
        input dma_m_araddr, dma_m_arid, dma_m_arlen, dma_m_arsize, dma_m_arburst;
        input dma_m_arlock, dma_m_arcache, dma_m_arprot, dma_m_arqos, dma_m_arregion;
        input dma_m_aruser, dma_m_arvalid, dma_m_arready;
        output dma_m_rdata, dma_m_rid, dma_m_rresp, dma_m_rlast, dma_m_rvalid, dma_m_rready;
        output dma_m_ruser;
    endclocking
    */

endinterface
