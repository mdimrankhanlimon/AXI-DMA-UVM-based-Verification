`timescale 1ns/1ps

module tb_top;
	`include "uvm_macros.svh"
	import uvm_pkg::* ;
	import top_pkg::* ;

	// interface declaration
	axi4lite_master_if m_intf();
	axi4_slave_if      s_intf();
	clk_rst_interface clk_intf();

	// interface instiation	
	tb_axi_dma dut(
		.clk(clk_intf.clk),
		.rst(clk_intf.rst_n),
		.dma_done_o(m_intf.dma_done_o),
		.dma_error_o(m_intf.dma_error_o),
		.dma_s_awaddr(m_intf.dma_s_awaddr),
		.dma_s_awprot(m_intf.dma_s_awprot),
		.dma_s_awvalid(m_intf.dma_s_awvalid),
		.dma_s_awready(m_intf.dma_s_awready),
		.dma_s_wdata(m_intf.dma_s_wdata),
		.dma_s_wstrb(m_intf.dma_s_wstrb),
		.dma_s_wvalid(m_intf.dma_s_wvalid),
		.dma_s_wready(m_intf.dma_s_wready),
		.dma_s_wlast(m_intf.dma_s_wlast),
		.dma_s_bready(m_intf.dma_s_bready),
		.dma_s_bresp(m_intf.dma_s_bresp),
		.dma_s_bvalid(m_intf.dma_s_bvalid),
		.dma_s_araddr(m_intf.dma_s_araddr),
		.dma_s_arprot(m_intf.dma_s_arprot),
		.dma_s_arvalid(m_intf.dma_s_arvalid),
		.dma_s_arready(m_intf.dma_s_arready),
		.dma_s_rdata(m_intf.dma_s_rdata),
		.dma_s_rresp(m_intf.dma_s_rresp),
		.dma_s_rvalid(m_intf.dma_s_rvalid),
		.dma_s_rready(m_intf.dma_s_rready),
		.dma_s_rlast(m_intf.dma_s_rlast),

		.dma_m_awaddr(s_intf.dma_m_awaddr),
		.dma_m_awid(s_intf.dma_m_awid),
		.dma_m_awlen(s_intf.dma_m_awlen),
		.dma_m_awsize(s_intf.dma_m_awsize),
		.dma_m_awburst(s_intf.dma_m_awburst),
		.dma_m_awlock(s_intf.dma_m_awlock),
		.dma_m_awcache(s_intf.dma_m_awcache),
		.dma_m_awprot(s_intf.dma_m_awprot),
		.dma_m_awqos(s_intf.dma_m_awqos),
		.dma_m_awregion(s_intf.dma_m_awregion),
		.dma_m_awuser(s_intf.dma_m_awuser),
		.dma_m_awvalid(s_intf.dma_m_awvalid),
		.dma_m_awready(s_intf.dma_m_awready),
		.dma_m_wdata(s_intf.dma_m_wdata),
		.dma_m_wstrb(s_intf.dma_m_wstrb),
		.dma_m_wlast(s_intf.dma_m_wlast),
		.dma_m_wvalid(s_intf.dma_m_wvalid),
		.dma_m_wready(s_intf.dma_m_wready),
		.dma_m_wuser(s_intf.dma_m_wuser),
		.dma_m_bready(s_intf.dma_m_bready),
		.dma_m_bid(s_intf.dma_m_bid),
		.dma_m_bresp(s_intf.dma_m_bresp),
		.dma_m_buser(s_intf.dma_m_buser),
		.dma_m_bvalid(s_intf.dma_m_bvalid),
		.dma_m_araddr(s_intf.dma_m_araddr),
		.dma_m_arid(s_intf.dma_m_arid),
		.dma_m_arlen(s_intf.dma_m_arlen),
		.dma_m_arsize(s_intf.dma_m_arsize),
		.dma_m_arburst(s_intf.dma_m_arburst),
		.dma_m_arlock(s_intf.dma_m_arlock),
		.dma_m_arcache(s_intf.dma_m_arcache),
		.dma_m_arprot(s_intf.dma_m_arprot),
		.dma_m_arqos(s_intf.dma_m_arqos),
		.dma_m_arregion(s_intf.dma_m_arregion),
		.dma_m_aruser(s_intf.dma_m_aruser),
		.dma_m_arvalid(s_intf.dma_m_arvalid),
		.dma_m_arready(s_intf.dma_m_arready),
		.dma_m_rdata(s_intf.dma_m_rdata),
		.dma_m_rid(s_intf.dma_m_rid),
		.dma_m_rresp(s_intf.dma_m_rresp),
		.dma_m_rlast(s_intf.dma_m_rlast),
		.dma_m_rvalid(s_intf.dma_m_rvalid),
		.dma_m_rready(s_intf.dma_m_rready),
		.dma_m_ruser(s_intf.dma_m_ruser)
	);

	assign m_intf.clk = clk_intf.clk;

	// initial block 
	initial begin 
		// clock-reset interface 
		uvm_config_db#(virtual clk_rst_interface)::set(null, "*", "CLK_RST_INTF", clk_intf);

		// axi master-slave interface
		uvm_config_db #(virtual axi4lite_master_if)::set (null,"*", "AXI4LITE_MASTER_INTF", m_intf);
		uvm_config_db #(virtual axi4_slave_if)::set (null,"*", "AXI4_SLAVE_INTF", s_intf);

		`uvm_info("tb_top", $sformatf("Statring test at system time"), UVM_NONE)
		run_test("sanity_simple_test");
	end: run_test

	// database dump
	initial begin 
		$dumpfile("dump.vcd");
		$dumpvars();
	end: dump_file

endmodule




