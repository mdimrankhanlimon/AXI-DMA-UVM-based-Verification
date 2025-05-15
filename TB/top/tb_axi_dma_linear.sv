`timescale 1ns/1ps

module tb_axi_dma_linear;

    // Parameters
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    // Clock and Reset
    bit clk;
    reg rst;

    // DMA IRQs
    wire dma_done_o;
    wire dma_error_o;

    // AXI4-Lite Slave Interface (for CSR configuration)
    reg [ADDR_WIDTH-1:0] dma_s_awaddr;
    reg [2:0] dma_s_awprot;
    reg dma_s_awvalid;
    wire dma_s_awready;
    reg [DATA_WIDTH-1:0] dma_s_wdata;
    reg [3:0] dma_s_wstrb;
    reg dma_s_wvalid;
    wire dma_s_wready;
    wire [1:0] dma_s_bresp;
    wire dma_s_bvalid;
    reg dma_s_bready;
    reg [ADDR_WIDTH-1:0] dma_s_araddr;
    reg [2:0] dma_s_arprot;
    reg dma_s_arvalid;
    wire dma_s_arready;
    wire [DATA_WIDTH-1:0] dma_s_rdata;
    wire [1:0] dma_s_rresp;
    wire dma_s_rvalid;
    reg dma_s_rready;

    // Master AXI I/F
    // AXI Interface - MOSI
    // Write Address channel
    logic       dma_m_awid;
    logic       dma_m_awaddr;
    logic       dma_m_awlen;
    logic       dma_m_awsize;
    logic       dma_m_awburst;
    logic       dma_m_awlock;
    logic [3:0] dma_m_awcache;
    logic       dma_m_awprot;
    logic [3:0] dma_m_awqos;
    logic [3:0] dma_m_awregion;
    logic       dma_m_awuser;
    logic       dma_m_awvalid;
    logic       dma_m_wdata;
    logic       dma_m_wstrb;
    logic       dma_m_wlast;
    logic       dma_m_wuser;
    logic       dma_m_wvalid;
    logic       dma_m_bready;
    logic       dma_m_arid;
    logic       dma_m_araddr;
    logic       dma_m_arlen;
    logic       dma_m_arsize;
    logic       dma_m_arburst;
    logic       dma_m_arlock;
    logic [3:0] dma_m_arcache;
    logic       dma_m_arprot;
    logic [3:0] dma_m_arqos;
    logic [3:0] dma_m_arregion;
    logic       dma_m_aruser;
    logic       dma_m_arvalid;
    logic       dma_m_rready;
   
    logic       dma_m_awready;
    logic       dma_m_wready;
    logic       dma_m_bid;
    logic       dma_m_bresp;
    logic       dma_m_buser;
    logic       dma_m_bvalid;
    logic       dma_m_arready;
    logic       dma_m_rid;
    logic       dma_m_rdata;
    logic       dma_m_rresp;
    logic       dma_m_rlast;
    logic       dma_m_ruser;
    logic       dma_m_rvalid;

    // Instantiate the AXI DMA Top Module
    tb_axi_dma uut (
        .clk(clk),
        .rst(rst),
        .dma_done_o(dma_done_o),
        .dma_error_o(dma_error_o),
        .dma_s_awaddr(dma_s_awaddr),
        .dma_s_awprot(dma_s_awprot),
        .dma_s_awvalid(dma_s_awvalid),
        .dma_s_awready(dma_s_awready),
        .dma_s_wdata(dma_s_wdata),
        .dma_s_wstrb(dma_s_wstrb),
        .dma_s_wvalid(dma_s_wvalid),
        .dma_s_wready(dma_s_wready),
        .dma_s_bresp(dma_s_bresp),
        .dma_s_bvalid(dma_s_bvalid),
        .dma_s_bready(dma_s_bready),
        .dma_s_araddr(dma_s_araddr),
        .dma_s_arprot(dma_s_arprot),
        .dma_s_arvalid(dma_s_arvalid),
        .dma_s_arready(dma_s_arready),
        .dma_s_rdata(dma_s_rdata),
        .dma_s_rresp(dma_s_rresp),
        .dma_s_rvalid(dma_s_rvalid),
        .dma_s_rready(dma_s_rready),

         .dma_m_awid   (dma_m_awid),
         .dma_m_awaddr (dma_m_awaddr),
         .dma_m_awlen  (dma_m_awlen),
         .dma_m_awsize (dma_m_awsize),
         .dma_m_awburst(dma_m_awburst),
         .dma_m_awlock (dma_m_awlock),
         .dma_m_awcache(dma_m_awcache),
         .dma_m_awprot (dma_m_awprot),
         .dma_m_awqos  (dma_m_awqos),
         .dma_m_awregion(dma_m_awregion),
         .dma_m_awuser (dma_m_awuser),
         .dma_m_awvalid(dma_m_awvalid),
         
         .dma_m_wdata  (dma_m_wdata),
         .dma_m_wstrb  (dma_m_wstrb),
         .dma_m_wlast  (dma_m_wlast),
         .dma_m_wuser  (dma_m_wuser),
         .dma_m_wvalid (dma_m_wvalid),
         .dma_m_bready (dma_m_bready),
         
         .dma_m_arid   (dma_m_arid),
         .dma_m_araddr (dma_m_araddr),
         .dma_m_arlen  (dma_m_arlen),
         .dma_m_arsize (dma_m_arsize),
         .dma_m_arburst(dma_m_arburst),
         .dma_m_arlock (dma_m_arlock),
         .dma_m_arcache(dma_m_arcache),
         .dma_m_arprot (dma_m_arprot),
         .dma_m_arqos  (dma_m_arqos),
         .dma_m_arregion(dma_m_arregion),
         .dma_m_aruser (dma_m_aruser),
         .dma_m_arvalid(dma_m_arvalid),
         .dma_m_rready (dma_m_rready),
         
         .dma_m_awready(dma_m_awready),
         .dma_m_wready (dma_m_wready),
         .dma_m_bid    (dma_m_bid),
         .dma_m_bresp  (dma_m_bresp),
         .dma_m_buser  (dma_m_buser),
         .dma_m_bvalid (dma_m_bvalid),
         .dma_m_arready(dma_m_arready),
         .dma_m_rid    (dma_m_rid),
         .dma_m_rdata  (dma_m_rdata),
         .dma_m_rresp  (dma_m_rresp),
         .dma_m_rlast  (dma_m_rlast),
         .dma_m_ruser  (dma_m_ruser),
         .dma_m_rvalid (dma_m_rvalid) 
    );

    // Clock Generation
    always #5 clk = ~clk;
/*
    // Test Sequence
    initial begin

	#20;
        rst = 1;

        #20;
	rst = 0; // Release reset
	#20;
        // CSR Configuration (Enable DMA and set burst length)
        dma_s_awaddr = 32'h00;
        dma_s_awprot = 3'b000;
        dma_s_awvalid = 1;
        dma_s_wdata = 32'h0000_0001; // Enable DMA
        dma_s_wstrb = 4'hF;
        dma_s_wvalid = 1;
        dma_s_bready = 1;
        #10 dma_s_awvalid = 0;
        dma_s_wvalid = 0;

        // Read Status Register
        dma_s_araddr = 32'h08;
        dma_s_arprot = 3'b000;
        dma_s_arvalid = 1;
        dma_s_rready = 1;
        #10 dma_s_arvalid = 0;
    
        #100;
        $finish;
    end
*/

// AXI-Lite Write Task
    task axi_lite_write;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        begin
            dma_s_awaddr = addr;
            dma_s_awvalid = 1;
            dma_s_wdata = data;
            dma_s_wstrb = 4'hF;
            dma_s_wvalid = 1;
            dma_s_bready = 1;
            #10;
            dma_s_awvalid = 0;
            dma_s_wvalid = 0;
        end
    endtask

    // AXI-Lite Read Task
    task axi_lite_read;
        input [ADDR_WIDTH-1:0] addr;
        begin
            dma_s_araddr = addr;
            dma_s_arprot = 3'b000;
            dma_s_arvalid = 1;
            dma_s_rready = 1;
            #10;
            dma_s_arvalid = 0;
        end
    endtask

    // Test Sequence
    initial begin
        clk = 0;
        rst = 1;
        #20 rst = 0; // Release reset

        // Read all registers before writing
        axi_lite_read(32'h00); // Read DMA Control
        axi_lite_read(32'h08); // Read DMA Status
        axi_lite_read(32'h10); // Read Error Address
        axi_lite_read(32'h18); // Read Error Stats
        axi_lite_read(32'h20); // Read Source Address
        axi_lite_read(32'h30); // Read Destination Address
        axi_lite_read(32'h40); // Read Num Bytes
        axi_lite_read(32'h50); // Read Descriptor Config

        // Configure single descriptor
        axi_lite_write(32'h20, 32'h1000_0000); // Set Source Address
        axi_lite_write(32'h30, 32'h2000_0000); // Set Destination Address
        axi_lite_write(32'h40, 32'h0000_0400); // Set Transfer Size (1024 bytes)
        axi_lite_write(32'h50, 32'h0000_0007); // Enable Descriptor
        axi_lite_write(32'h00, 32'h0000_0001); // Start DMA

        // Wait for completion
        repeat (20) #10;

        // Read all registers again
        axi_lite_read(32'h00); // Read DMA Control
        axi_lite_read(32'h08); // Read DMA Status
        axi_lite_read(32'h10); // Read Error Address
        axi_lite_read(32'h18); // Read Error Stats
        axi_lite_read(32'h20); // Read Source Address
        axi_lite_read(32'h30); // Read Destination Address
        axi_lite_read(32'h40); // Read Num Bytes
        axi_lite_read(32'h50); // Read Descriptor Config
    
        #100;
        $finish;
    end


endmodule



