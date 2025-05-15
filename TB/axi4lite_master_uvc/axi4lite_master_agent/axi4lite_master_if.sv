interface axi4lite_master_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32, ID_WIDTH = 4) ();
    
    // Clock and Reset Signals
    bit clk;             // Clock signal
    logic rst_n;           // Active low reset signal

    // DMA IRQs
    logic                    dma_done_o;
    logic                    dma_error_o;

    // Write Address Channel (AW)
    logic [ADDR_WIDTH-1:0] dma_s_awaddr;  // Write address
    logic [ID_WIDTH-1:0] dma_s_awprot;    // Protection type
    logic dma_s_awvalid;                  // Write address valid
    logic dma_s_awready;                  // Write address ready

    // Write Data Channel (W)
    logic [DATA_WIDTH-1:0] dma_s_wdata;   // Write data
    logic [DATA_WIDTH/8-1:0] dma_s_wstrb; // Write strobes
    logic dma_s_wvalid;                   // Write valid
    logic dma_s_wready;                   // Write ready
    logic dma_s_wlast;                    // Write last (end of burst)

    // Write Response Channel (B)
    logic dma_s_bready;                  // Write response ready
    logic [1:0] dma_s_bresp;             // Write response
    logic dma_s_bvalid;                  // Write response valid

    // Read Address Channel (AR)
    logic [ADDR_WIDTH-1:0] dma_s_araddr;  // Read address
    logic [ID_WIDTH-1:0] dma_s_arprot;    // Protection type
    logic dma_s_arvalid;                  // Read address valid
    logic dma_s_arready;                  // Read address ready

    // Read Data Channel (R)
    logic [DATA_WIDTH-1:0] dma_s_rdata;  // Read data
    logic [1:0] dma_s_rresp;             // Read response
    logic dma_s_rvalid;                  // Read valid
    logic dma_s_rready;                  // Read ready
    logic dma_s_rlast;                   // Read last (end of burst)


    // Modport for AXI Slave
    modport master (
		   	input clk, rst_n,
                   	input dma_s_awaddr, dma_s_awprot, dma_s_awvalid, 
                   	output dma_s_awready,
                   	input dma_s_wdata, dma_s_wstrb, dma_s_wvalid, dma_s_wlast,
                   	output dma_s_wready,
                   	output dma_s_bresp, dma_s_bvalid, dma_s_bready,
                   	input dma_s_araddr, dma_s_arprot, dma_s_arvalid,
                   	output dma_s_arready,
                   	output dma_s_rdata, dma_s_rresp, dma_s_rvalid, dma_s_rready, dma_s_rlast
		  );

    // Clocking block for AXI Slave
    clocking master_cb @(posedge clk);
        input dma_s_awaddr, dma_s_awprot, dma_s_awvalid, dma_s_awready;
        input dma_s_wdata, dma_s_wstrb, dma_s_wvalid, dma_s_wready, dma_s_wlast;
        input dma_s_bresp, dma_s_bvalid, dma_s_bready;
        input dma_s_araddr, dma_s_arprot, dma_s_arvalid, dma_s_arready;
        input dma_s_rdata, dma_s_rresp, dma_s_rvalid, dma_s_rready, dma_s_rlast;
    endclocking

endinterface
