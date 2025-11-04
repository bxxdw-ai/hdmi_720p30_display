`timescale 1ns/1ps

//`include "ddr3_controller.vh"


module example_top 
(
	////////////////////////////////////////////////////////////////
	//	External Clock & Reset
	//input 			nrst, 			//	Button K2
	input 			clk_24m,			//	24MHz Crystal
	input 			clk_25m,			//	25MHz Crystal 
	
	
	////////////////////////////////////////////////////////////////
	//	System Clock
	output 			sys_pll_rstn_o, 		
	
	input 			clk_sys,			//	Sys PLL 96MHz 
	input 			clk_pixel,			//	Sys PLL 74.25MHz
	input 			clk_pixel_2x,		//	Sys PLL 148.5MHz
	input 			clk_pixel_10x,		//	Sys PLL 742.5MHz
	
	input 			sys_pll_lock,		//	Sys PLL Lock
	
	// [已移除] MIPI-DSI Clock & Reset
	// [已移除] LVDS Clock
	
	////////////////////////////////////////////////////////////////
	//	DDR Clock
	output 			ddr_pll_rstn_o, 
	
	input 			tdqss_clk,			
	input 			core_clk,			//	DDR PLL 200MHz
	input 			tac_clk,			
	input 			twd_clk,			
	
	input 			ddr_pll_lock,		//	DDR PLL Lock
	
	////////////////////////////////////////////////////////////////
	//	DDR PLL Phase Shift Interface
	output 	[2:0] 	shift,
	output 	[4:0] 	shift_sel,
	output 			shift_ena,
	
	
	////////////////////////////////////////////////////////////////
	//	DDR Interface Ports
	output 	[15:0] 	addr,
	output 	[2:0] 	ba,
	output 			we,
	output 			reset,
	output 			ras,
	output 			cas,
	output 			odt,
	output 			cke,
	output 			cs,
	
	//	DQ I/O
	input 	[15:0] 	i_dq_hi,
	input 	[15:0] 	i_dq_lo,
	
	output 	[15:0] 	o_dq_hi,
	output 	[15:0] 	o_dq_lo,
	output 	[15:0] 	o_dq_oe,
	
	//	DM O
	output 	[1:0] 	o_dm_hi,
	output 	[1:0] 	o_dm_lo,
	
	//	DQS I/O
	input 	[1:0] 	i_dqs_hi,
	input 	[1:0] 	i_dqs_lo,
	
	input 	[1:0] 	i_dqs_n_hi,
	input 	[1:0] 	i_dqs_n_lo,
	
	output 	[1:0] 	o_dqs_hi,
	output 	[1:0] 	o_dqs_lo,
	
	output 	[1:0] 	o_dqs_n_hi, // [拼写修复]
	output 	[1:0] 	o_dqs_n_lo,
	
	output 	[1:0] 	o_dqs_oe,
	output 	[1:0] 	o_dqs_n_oe,
	
	//	CK
	output 			clk_p_hi, 
	output 			clk_p_lo, 
	output 			clk_n_hi, 
	output 			clk_n_lo, 
	
	
	
	////////////////////////////////////////////////////////////////
	//	MIPI-CSI Ctl / I2C
	output 			csi_ctl0_o,
	output 			csi_ctl0_oe,
	input 			csi_ctl0_i,
	
	output 			csi_ctl1_o,
	output 			csi_ctl1_oe,
	input 			csi_ctl1_i,
	
	output 			csi_scl_o,
	output 			csi_scl_oe,
	input 			csi_scl_i,
	
	output 			csi_sda_o,
	output 			csi_sda_oe,
	input 			csi_sda_i,
	
	//	MIPI-CSI RXC 
	input 			csi_rxc_lp_p_i,
	input 			csi_rxc_lp_n_i,
	output 			csi_rxc_hs_en_o,
	output 			csi_rxc_hs_term_en_o,
	input 			csi_rxc_i,
	
	//	MIPI-CSI RXD0
	output 			csi_rxd0_rst_o,
	output 			csi_rxd0_hs_en_o,
	output 			csi_rxd0_hs_term_en_o,
	
	input 			csi_rxd0_lp_p_i,
	input 			csi_rxd0_lp_n_i,
	input 	[7:0] 	csi_rxd0_hs_i,
	
	//	MIPI-CSI RXD1
	output 			csi_rxd1_rst_o,
	output 			csi_rxd1_hs_en_o,
	output 			csi_rxd1_hs_term_en_o,
	
	input 			csi_rxd1_lp_n_i,
	input 			csi_rxd1_lp_p_i,
	input 	[7:0] 	csi_rxd1_hs_i,
	
	//	MIPI-CSI RXD2
	output 			csi_rxd2_rst_o,
	output 			csi_rxd2_hs_en_o,
	output 			csi_rxd2_hs_term_en_o,
	
	input 			csi_rxd2_lp_p_i,
	input 			csi_rxd2_lp_n_i,
	input 	[7:0] 	csi_rxd2_hs_i,
	
	//	MIPI-CSI RXD3
	output 			csi_rxd3_rst_o,
	output 			csi_rxd3_hs_en_o,
	output 			csi_rxd3_hs_term_en_o,
	
	input 			csi_rxd3_lp_p_i,
	input 			csi_rxd3_lp_n_i,
	input 	[7:0] 	csi_rxd3_hs_i,
	
	// [已移除] DSI PWM & Reset Control
	// [已移除] MIPI-DSI TXC / TXD
	
	
	////////////////////////////////////////////////////////////////
	//	UART Interface
	input 		 	uart_rx_i,			//	Support 460800-8-N-1.
	output 		 	uart_tx_o, 
	
	
	output 	[5:0] 	led_o,			//	
	
	
	////////////////////////////////////////////////////////////////
	//	CMOS Sensor
	output 			cmos_sclk,
	input 			cmos_sdat_IN,
	output 			cmos_sdat_OUT,
	output 			cmos_sdat_OE,
	
	//	CMOS Interface
	input 			cmos_pclk,
	input 			cmos_vsync,
	input 			cmos_href,
	input 	[7:0] 	cmos_data,
	input 			cmos_ctl1,
	output 			cmos_ctl2,
	output 			cmos_ctl3,
	
	
	////////////////////////////////////////////////////////////////
	//	HDMI Interface
	output 			hdmi_txc_oe,
	output 			hdmi_txd0_oe,
	output 			hdmi_txd1_oe,
	output 			hdmi_txd2_oe,
	
	output 			hdmi_txc_rst_o,
	output 			hdmi_txd0_rst_o,
	output 			hdmi_txd1_rst_o,
	output 			hdmi_txd2_rst_o,
	
	output 	[9:0] 	hdmi_txc_o,
	output 	[9:0] 	hdmi_txd0_o,
	output 	[9:0] 	hdmi_txd1_o,
	output 	[9:0] 	hdmi_txd2_o,
	
	
	// [已移除] LVDS Interface
	
	
	////////////////////////////////////////////////////////////////
	//	RGB LCD 5Inch 800x480 (相关端口, 保留用于SPI)
	output 			lcd_tp_sda_o,		//	TP SDA
	output 			lcd_tp_sda_oe,
	input 			lcd_tp_sda_i,
	
	output 			lcd_tp_scl_o,		//	TP SCL
	output 			lcd_tp_scl_oe,
	input 			lcd_tp_scl_i,
	
	output 			lcd_tp_int_o,		//	TP INT
	output 			lcd_tp_int_oe,
	input 			lcd_tp_int_i,
	
	output 			lcd_tp_rst_o,		//	TP RST
	
	output 			lcd_pwm_o,			//	Backlight
	output 			lcd_blen_o,
	
	//output 			lcd_pclk_o,			//	PCLK & SCK Mux
	output 			lcd_vs_o,			//	VS & SSN Mux. Fixed to 1 Use DE-Only mode.
	output 			lcd_hs_o,			//	HS. Fixed to 1 Use DE-Only mode.
	output 			lcd_de_o,			//	DE.

	output 	[7:0] 	lcd_b7_0_o,			//	B7:B0.
	output 	[7:0] 	lcd_g7_0_o,			//	G7:G0. Must output 8'hFF when access SPI.
	output 	[7:0] 	lcd_r7_0_o,			//	R7:R0.
	
	output 	[7:0] 	lcd_b7_0_oe,		//	B7:B0.
	output 	[7:0] 	lcd_g7_0_oe,		//	G7:G0.
	output 	[7:0] 	lcd_r7_0_oe,		//	R7:R0.

	input 	[7:0] 	lcd_b7_0_i,			//	B7:B0.
	input 	[7:0] 	lcd_g7_0_i,			//	G7:G0.
	input 	[7:0] 	lcd_r7_0_i,			//	R7:R0.
	
	//	SPI Pins
	output 			spi_sck_o, 
	output 			spi_ssn_o 			
);
	
	wire 			csi_rxd0_fifo_rd_o;
	wire 			csi_rxd0_fifo_empty_i = 0;
	wire 			csi_rxd1_fifo_rd_o;  
	wire 			csi_rxd1_fifo_empty_i = 0;
	wire 			csi_rxd2_fifo_rd_o;  
	wire 			csi_rxd2_fifo_empty_i = 0;
	wire 			csi_rxd3_fifo_rd_o;
	wire 			csi_rxd3_fifo_empty_i = 0;
	
	
	parameter 	SIM_DATA 	= 0; 
	
	//	Hardware Configuration
	assign clk_p_hi = 1'b0;	//	DDR3 Clock requires 180 degree shifted.
	assign clk_p_lo = 1'b1;
	assign clk_n_hi = 1'b1;
	assign clk_n_lo = 1'b0;
	
	//	System Clock Tree Control
	assign sys_pll_rstn_o = 1'b1; 	//	nrst;
	// [已移除] DSI 和 LVDS PLL 控制
	assign ddr_pll_rstn_o = sys_pll_lock;
	wire 			w_pll_lock = sys_pll_lock && ddr_pll_lock;
	// [修改] 移除了 dsi 和 lvds lock
	
	//	Synchronize System Resets.
	reg 			rstn_sys = 0, rstn_pixel = 0;
	wire 			rst_sys = ~rstn_sys, rst_pixel = ~rstn_pixel;
	// [已移除] DSI 和 LVDS 时钟复位
	// reg 			rstn_27m = 0, rstn_54m = 0;
	// wire 			rst_27m = ~rstn_27m, rst_54m = ~rstn_54m; 
	//	Clock Gen
	// [VERI-1128 错误修复] 注释掉以下4行
	// always @(posedge clk_27m or negedge w_pll_lock) begin if(~w_pll_lock) rstn_27m <= 0;
	// else rstn_27m <= 1; end
	// always @(posedge clk_54m or negedge w_pll_lock) begin if(~w_pll_lock) rstn_54m <= 0;
	// else rstn_54m <= 1;
	// end
	always @(posedge clk_sys or negedge w_pll_lock) begin if(~w_pll_lock) rstn_sys <= 0;
	else rstn_sys <= 1;
	end
	always @(posedge clk_pixel or negedge w_pll_lock) begin if(~w_pll_lock) rstn_pixel <= 0; else rstn_pixel <= 1;
	end
	
	
	localparam 	CLOCK_MAIN 	= 96000000;
	//	System clock using 96MHz.
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	Flash Burner Control
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire 			w_ustick, w_mstick; 
	
	wire  [7:0] 	w_dev_index_o;
	wire  [7:0] 	w_dev_cmd_o;
	wire  [31:0] 	w_dev_wdata_o;
	wire  		w_dev_wvalid_o;  
	wire  		w_dev_rvalid_o;  
	wire 	[31:0] 	w_dev_rdata_i;  
	
	wire 			w_spi_ssn_o, w_spi_sck_o;
	wire 	[3:0] 	w_spi_data_o, w_spi_data_oe;
	wire 	[3:0] 	w_spi_data_i;
	
	//	Flash Control
	reg 			r_flash_en = 0;
	//	0x00:0x00 Enable Flash
	
	always @(posedge clk_sys) begin
		r_flash_en <= (w_dev_wvalid_o && (w_dev_index_o == 8'h00) && (w_dev_cmd_o == 8'h00)) ?
		w_dev_wdata_o : r_flash_en;
	end
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	LCD Data Mux
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire 	[7:0] 	w_lcd_b_o, w_lcd_g_o, w_lcd_r_o; 
	
	assign lcd_b7_0_o = r_flash_en ? {4'b0, w_spi_data_o[3:2], 2'b0} : w_lcd_b_o;
	assign lcd_g7_0_o = r_flash_en ? {6'h0, w_spi_data_o[1:0]} : w_lcd_g_o;
	assign lcd_r7_0_o = r_flash_en ? {8'h00} : w_lcd_r_o;
	assign lcd_b7_0_oe = r_flash_en ? {4'b0, w_spi_data_oe[3:2], 2'b0} : 8'hFF;
	assign lcd_g7_0_oe = r_flash_en ? {6'h0, w_spi_data_oe[1:0]} : 8'hFF;
	assign lcd_r7_0_oe = r_flash_en ? {8'h00} : 8'hFF;
	
	assign spi_sck_o = w_spi_sck_o;
	assign spi_ssn_o = w_spi_ssn_o;
	assign w_spi_data_i = {lcd_b7_0_i[3:2], lcd_g7_0_i[1:0]};
	
	
	
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DDR3 Controller
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	wire			w_ddr3_ui_clk = clk_sys;
	wire			w_ddr3_ui_rst = rst_sys;
	wire			w_ddr3_ui_areset = rst_sys;
	wire			w_ddr3_ui_aresetn = rstn_sys;
	//	General AXI Interface
	wire	[3:0] 	w_ddr3_awid;
	wire	[31:0]	w_ddr3_awaddr;
	wire	[7:0]		w_ddr3_awlen;
	wire			w_ddr3_awvalid;
	wire			w_ddr3_awready;
	
	wire 	[3:0]  	w_ddr3_wid;
	wire 	[127:0] 	w_ddr3_wdata;
	wire 	[15:0]	w_ddr3_wstrb;
	wire			w_ddr3_wlast;
	wire			w_ddr3_wvalid;
	wire			w_ddr3_wready;
	wire 	[3:0] 	w_ddr3_bid;
	wire 	[1:0] 	w_ddr3_bresp;
	wire			w_ddr3_bvalid;
	wire			w_ddr3_bready;
	
	wire	[3:0] 	w_ddr3_arid;
	wire	[31:0]	w_ddr3_araddr;
	wire	[7:0]		w_ddr3_arlen;
	wire			w_ddr3_arvalid;
	wire			w_ddr3_arready;
	
	wire 	[3:0] 	w_ddr3_rid;
	wire 	[127:0] 	w_ddr3_rdata;
	wire			w_ddr3_rlast;
	wire			w_ddr3_rvalid;
	wire			w_ddr3_rready;
	wire 	[1:0] 	w_ddr3_rresp;
	
	
	//	AXI Interface Request
	wire 	[3:0] 	w_ddr3_aid;
	wire 	[31:0] 	w_ddr3_aaddr;
	wire 	[7:0]  	w_ddr3_alen;
	wire 	[2:0]  	w_ddr3_asize;
	wire 	[1:0]  	w_ddr3_aburst;
	wire 	[1:0]  	w_ddr3_alock;
	wire			w_ddr3_avalid;
	wire			w_ddr3_aready;
	wire			w_ddr3_atype;
	wire 			w_ddr3_cal_done, w_ddr3_cal_pass;
	//	Do not issue DDR read / write when ~cal_done. 
	reg 			r_ddr_unlock = 0;
	always @(posedge w_ddr3_ui_clk or negedge w_ddr3_ui_aresetn) begin
		if(~w_ddr3_ui_aresetn)
			r_ddr_unlock <= 0; 
		else
			r_ddr_unlock <= w_ddr3_cal_done;
	end
	
	DdrCtrl ddr3_ctl_axi (	
		.core_clk		(core_clk),
		.tac_clk		(tac_clk),
		.twd_clk		(twd_clk),	
		.tdqss_clk		(tdqss_clk),
		
		.reset		(reset),
		.cs			(cs),
		.ras			(ras),
		.cas			(cas),
		.we			(we),
		.cke			(cke),    
		.addr			(addr),
		.ba			(ba),
		.odt			(odt),
		
		.o_dm_hi		(o_dm_hi),
		.o_dm_lo		(o_dm_lo),
		
		.i_dq_hi		(i_dq_hi),
		.i_dq_lo		(i_dq_lo),
		.o_dq_hi		(o_dq_hi),
		.o_dq_lo		(o_dq_lo),
		.o_dq_oe		(o_dq_oe),
		
		.i_dqs_hi		(i_dqs_hi),
		.i_dqs_lo		(i_dqs_lo),
		.i_dqs_n_hi		(i_dqs_n_hi),
		.i_dqs_n_lo		(i_dqs_n_lo),
		.o_dqs_hi		(o_dqs_hi),
		.o_dqs_lo		(o_dqs_lo),
		.o_dqs_n_hi		(o_dqs_n_hi),
		.o_dqs_n_lo		(o_dqs_n_lo),
		.o_dqs_oe		(o_dqs_oe),
		.o_dqs_n_oe		(o_dqs_n_oe),
		
		.clk			(w_ddr3_ui_clk),
		.reset_n		(w_ddr3_ui_aresetn),
		
		.axi_avalid		(w_ddr3_avalid && r_ddr_unlock),	//	Enable command only when unlocked. 
		.axi_aready		(w_ddr3_aready),
		.axi_aaddr		(w_ddr3_aaddr),
		.axi_aid		(w_ddr3_aid),
		.axi_alen		(w_ddr3_alen),
		.axi_asize		(w_ddr3_asize),
		.axi_aburst		(w_ddr3_aburst),
		.axi_alock		(w_ddr3_alock),
		.axi_atype		(w_ddr3_atype),
		
		.axi_wid		(w_ddr3_wid),
		.axi_wvalid		(w_ddr3_wvalid),
		.axi_wready		(w_ddr3_wready),
		.axi_wdata		(w_ddr3_wdata),
		.axi_wstrb		(w_ddr3_wstrb),
		.axi_wlast		(w_ddr3_wlast),
		
		.axi_bvalid		(w_ddr3_bvalid),
		.axi_bready		(w_ddr3_bready),
		.axi_bid		(w_ddr3_bid),
		.axi_bresp		(w_ddr3_bresp),
		
		.axi_rvalid		(w_ddr3_rvalid),
		.axi_rready		(w_ddr3_rready),
		.axi_rdata		(w_ddr3_rdata),
		.axi_rid		(w_ddr3_rid),
		.axi_rresp		(w_ddr3_rresp),
		.axi_rlast		(w_ddr3_rlast),
		
		.shift		(shift),
		.shift_sel		(),
		.shift_ena		(shift_ena),
		
		.cal_ena		(1'b1),
		.cal_done		(w_ddr3_cal_done),
		.cal_pass		(w_ddr3_cal_pass)
	);
	
	assign w_ddr3_bready = 1'b1;
	assign shift_sel = 5'b00100; 		//	ddr_tac_clk always use PLLOUT[2].
	
	
	AXI4_AWARMux #(.AID_LEN(4), .AADDR_LEN(32)) axi4_awar_mux (
		.aclk_i			(w_ddr3_ui_clk), 
		.arst_i			(w_ddr3_ui_rst), 
		
		.awid_i			(w_ddr3_awid),
		.awaddr_i			(w_ddr3_awaddr),
		.awlen_i			(w_ddr3_awlen),
		.awvalid_i			(w_ddr3_awvalid),
		.awready_o			(w_ddr3_awready),
		
		.arid_i			(w_ddr3_arid),
		.araddr_i			(w_ddr3_araddr),
		.arlen_i			(w_ddr3_arlen),
		.arvalid_i			(w_ddr3_arvalid),
		.arready_o			(w_ddr3_arready),
		
		.aid_o			(w_ddr3_aid),
		.aaddr_o			(w_ddr3_aaddr),
		.alen_o			(w_ddr3_alen),
		.atype_o			(w_ddr3_atype),
		.avalid_o			(w_ddr3_avalid),
		.aready_i			(w_ddr3_aready)
	);
	
	assign w_ddr3_asize = 4;
	//	Fixed 128 bits (16 bytes, size = 4)
	assign w_ddr3_aburst = 1;
	assign w_ddr3_alock = 0;
	
	//assign led_o[1:0] = {w_ddr3_cal_pass, w_ddr3_cal_done};
	////////////////////////////////////////////////////////////////
	//	I2C Config (SC130GS)
	
	//  i2c timing controller module of 16Bit
	wire            [ 7:0]          sc130_i2c_config_index;
	wire            [23:0]          sc130_i2c_config_data;
	wire            [ 7:0]          sc130_i2c_config_size;
	wire                            sc130_i2c_config_done;
	i2c_timing_ctrl_16bit
	#(
	    .CLK_FREQ           (CLOCK_MAIN),                              //  100 MHz
	    .I2C_FREQ           (10_000    )                               //  10 KHz(<= 400KHz)
	) u_i2c_timing_ctrl_16bit (
	    //  global clock
	    .clk                (clk_sys                 ),                          //  96MHz
	    .rst_n              (rstn_sys                  ),                          //  system reset

	    //  i2c interface
	    .i2c_sclk           (csi_scl_o               ),                         //  i2c clock
	    .i2c_sdat_IN        (csi_sda_i               ),
	    .i2c_sdat_OUT       (csi_sda_o               ),
	    .i2c_sdat_OE        (csi_sda_oe              ),

	    //  i2c config data
	    .i2c_config_index   (sc130_i2c_config_index          ),                          //  i2c config reg index, read 2 reg and write xx reg
	    .i2c_config_data    ({8'h6a, sc130_i2c_config_data}),                     //  i2c config data
	    .i2c_config_size    (sc130_i2c_config_size         ),                        //  i2c config data counte
	    .i2c_config_done    (sc130_i2c_config_done         ),                          //  i2c config timing complete


		.config_clk         (w_csi_rx_clk                  ),
		.config_data        (config_data               ),
		.config_data_valid  (config_data_valid         ) 
	
		);
	assign csi_scl_oe = 1;

	//  I2C Configure Data of SC130GS
	I2C_AD2020_1280960_FPS60_1Lane_Config u_I2C_AD2020_1280960_FPS60_1Lane_Config 
	(
	    .LUT_INDEX  (sc130_i2c_config_index   ),
	    .LUT_DATA   (sc130_i2c_config_data    ),
	    .LUT_SIZE   (sc130_i2c_config_size    )
	);
	//	Output LED
	reg 	[3:0]		r_cmos_fv_o = 0;
	reg 	[1:0] 	r_cmos_rx_vsync0_in = 0;
	always @(posedge cmos_pclk) begin
		r_cmos_rx_vsync0_in <= {r_cmos_rx_vsync0_in, cmos_vsync};
		r_cmos_fv_o <= r_cmos_fv_o + ((r_cmos_rx_vsync0_in == 2'b01) ? 1 : 0);
	end
	// assign led_o[5] = r_cmos_fv_o[3]; 
	assign led_o[5] = csi_rxc_i;
	////////////////////////////////////////////////////////////////
	//	System Control. Can be removed for public.
	
	localparam 	CLK_FREQ 	= 96_000_000; 	//	clk_sys is 96MHz.
	localparam 	BAUD_RATE 	= 460_800; 		//	Use 460800-8-N-1.
	//	SFR I/O Interface
	wire 	[7:0] 	w_sfr_addr_o; 	//	SFR Address (0xFF00 ~ 0xFFFF). 00:Power; 40~5F:Stream0; 60~7F:Stream1.
	wire 	[7:0] 	w_sfr_wdata_o; 	//	SFR Write Data.
	wire 			w_sfr_we_o; 		//	SFR WE.
	reg 	[7:0] 	w_sfr_rdata_i; 	//	Must be valid after sfr_rd_o.
	wire 			w_sfr_rd_o; 		//	SFR RD.
	// [已移除] DSI Control Registers
	
	//	AXI-Lite Interface Bridge
	localparam 	CSI_AXILITE_ID 	= 0; 				//	Select DSI_TX when r_axi_sel = DSI_AXILITE_ID.
	localparam 	DSI_AXILITE_ID 	= 1;
	//	Select DSI_TX when r_axi_sel = DSI_AXILITE_ID.
	
	reg 	[7:0] 	r_axi_addr = 8'h18; 		//	0xE0 (RW)
	reg 	[31:0] 	r_axi_wdata = 32'h0000000A;
	//	0xE1~0xE4 (RW)
	wire 	[31:0] 	w_axi_rdata; 			//	0xE5~0xE8 (RO)
	reg 	[0:0] 	r_axi_sel = 1; 			//	0xE9[7:2] (RW)
	reg 			r_axi_r1w0 = 0; 			//	0xE9[1] (RW)
	reg 			r_axi_req = 0;
	//	0xE9[0] (WO, Single Cycle)
	reg 			r_axi_req_o = 0; 			//	Delayed of r_axi_req.
	
	
	//	Buffered AXI Read Data
	reg 	[31:0] 	r_axi_rdata = 0;
	//	Use state machine
	reg 			r_axi_idle = 0; 		//	AXI Idle
	
	reg 	[3:0] 	rs_axilite = 0; 		//	AXI Access
	wire 	[3:0] 	ws_axilite_idle = 0;
	wire 	[3:0] 	ws_axilite_write = 1;
	wire 	[3:0] 	ws_axilite_read = 2;
	wire 	[3:0] 	ws_axilite_endread = 3;
	reg 			r_axi_awvalid = 0, r_axi_wvalid = 0, r_axi_arvalid = 0;
	wire 			w_axi_awready, w_axi_wready, w_axi_arready, w_axi_rvalid; 
	
	
	reg 	[3:0] 	rc_axi_init = 0;
	always @(posedge clk_sys or posedge rst_sys) begin
		if(rst_sys) begin
			// [已移除] DSI Resets
			r_axi_req <= 0; 
			
			rs_axilite <= 0; 
			r_axi_awvalid <= 0;
			r_axi_wvalid <= 0;
			r_axi_arvalid <= 0; 
			
			rc_axi_init <= 0; 
			r_axi_idle <= 0;
		end else begin
			// [已移除] DSI Resets
		end
	end
	
	// [已移除] DSI PWM
	
	assign csi_ctl0_oe = 0;
	assign csi_ctl1_oe = 0;
	// --- AE (自动曝光) Wires ---
	wire [7:0]  w_avg_brightness;   // AE 统计的平均亮度
	wire        w_frame_done;
	// AE 帧结束信号
	wire [15:0] w_ae_gain_q8_8;     // AE 控制器计算的 Q8.8 增益
	
	// --- Wires for Vignetting Correction ---
	wire [10:0] w_rgb_h_cnt;
	wire [10:0] w_rgb_v_cnt;
	wire        w_vignette_vsync;
	wire        w_vignette_valid;
	wire [7:0]  w_vignette_r;
	wire [7:0]  w_vignette_g;
	wire [7:0]  w_vignette_b;
	
	////////////////////////////////////////////////////////////////
	//	MIPI CSI RX
	wire                                    empty_o                    ;
	wire                                    wr_en                      ;
	wire                   [  31:0]         wr_data                    ;
	wire                   [   7:0]         rd_data                    ;
	wire                                    prepare_vsync              ;
	wire                                    prepare_valid              ;
	wire                   [   7:0]         prepare_data               ;
	wire                   [  10:0]         rd_count                   ;
	reg                                     rd_en                      ;
	reg                    [  10:0]         pixel_cnt                  ;
	//	The CSI RXC shall not be inverted. Data can be inverted with swapped LP data and flipped HS data.
	// localparam 	CSI_RXD_INV 	= 4'b1111;
	// localparam 	CSI_RXD_INV 	= 4'b0000; 
	localparam 	CSI_RXD_INV 	= 4'b0000; 
	// localparam 	CSI_RXD_INV 	= 4'b0001;
	localparam 	CSI_DATA_WIDTH 	= 8;
	localparam 	CSI_STRB_WIDTH 	= CSI_DATA_WIDTH / 8;

	//	Current implementation supports RAW8 only. 
	wire 			w_csi_rx_clk;
	// [FIX] 关键时钟修复: 将 ISP 时钟 (w_csi_rx_clk) 锁定到像素时钟 (clk_pixel)
	assign w_csi_rx_clk = clk_pixel; // 74.25MHz
	
	wire 			w_csi_rx_vsync0, w_csi_rx_hsync0, w_csi_rx_dvalid; 
	wire 	[63:0] 	w_csi_rx_data;
	wire 	[47:0] 	w_csi_rx_data_rel_raw;
	
	//	AXI Interface
	wire 	[31:0] 	w_csi_axi_rdata; 
	wire 			w_csi_axi_awready, w_csi_axi_wready, w_csi_axi_arready, w_csi_axi_rvalid; 
	wire [7:0] data_typer;
	//	Reset pixel 16 cycles after ~vsync.
	reg 			r_reset_pixen_n = 0;
	reg 	[1:0] 	r_csi_rx_vsync0_i = 0;
	reg 	[3:0] 	rc_csi_rx_vsync0_f = 0;
	always @(posedge w_csi_rx_clk or negedge rstn_sys) begin
		if(~rstn_sys) begin
			r_reset_pixen_n <= 0; 
			r_csi_rx_vsync0_i <= 0; 
			rc_csi_rx_vsync0_f <= 0;
		end else begin
			r_csi_rx_vsync0_i <= {r_csi_rx_vsync0_i, w_csi_rx_vsync0}; 
			if(r_csi_rx_vsync0_i == 2'b10) 
				rc_csi_rx_vsync0_f <= 1; 
			else
				rc_csi_rx_vsync0_f <= rc_csi_rx_vsync0_f + (|rc_csi_rx_vsync0_f);
			r_reset_pixen_n <= (&rc_csi_rx_vsync0_f) ? 0 : 1;
		end
	end

	// `define PRI_IP
	`ifdef PRI_IP
	wire 	[7:0] 	w_mipi_d0 = (CSI_RXD_INV[0] ? 8'hFF : 8'h00) ^ csi_rxd0_hs_i;
	wire 	[7:0] 	w_mipi_d1 = (CSI_RXD_INV[1] ? 8'hFF : 8'h00) ^ csi_rxd1_hs_i;
	wire 	[7:0] 	w_mipi_d2 = (CSI_RXD_INV[2] ? 8'hFF : 8'h00) ^ csi_rxd2_hs_i;
	wire 	[7:0] 	w_mipi_d3 = (CSI_RXD_INV[3] ? 8'hFF : 8'h00) ^ csi_rxd3_hs_i;
	MIPIRx1LaneFre mipi0_rx (
		.sclk_i			(clk_sys), 
		.srst_i			(rst_sys), 
		
		.mipi_rx_byteclk_i	(csi_rxc_i), 
		.mipi_rx_d0_i		({w_mipi_d0[0], w_mipi_d0[1], w_mipi_d0[2], w_mipi_d0[3], w_mipi_d0[4], w_mipi_d0[5], w_mipi_d0[6], w_mipi_d0[7]}), 
		.mipi_rx_d1_i		({w_mipi_d1[0], w_mipi_d1[1], w_mipi_d1[2], w_mipi_d1[3], w_mipi_d1[4], w_mipi_d1[5], w_mipi_d1[6], w_mipi_d1[7]}), 
		.mipi_rx_d2_i		({w_mipi_d2[0], w_mipi_d2[1], w_mipi_d2[2], w_mipi_d2[3], w_mipi_d2[4], w_mipi_d2[5], w_mipi_d2[6], w_mipi_d2[7]}), 
		.mipi_rx_d3_i		({w_mipi_d3[0], w_mipi_d3[1], w_mipi_d3[2], w_mipi_d3[3], w_mipi_d3[4], w_mipi_d3[5], w_mipi_d3[6], w_mipi_d3[7]}), 
		.mipi_rx_clk_lp_p_i	(csi_rxc_lp_p_i), 
		.mipi_rx_clk_lp_n_i	(csi_rxc_lp_n_i), 
		.mipi_rx_d0_lp_p_i	(CSI_RXD_INV[0] ? csi_rxd0_lp_n_i : csi_rxd0_lp_p_i), 
		.mipi_rx_d0_lp_n_i	(CSI_RXD_INV[0] ? csi_rxd0_lp_p_i : csi_rxd0_lp_n_i), 
		.mipi_rx_rst_o		(), 
		.mipi_rx_rst_n_o		(), 
		.mipi_rx_clk_hs_en_o	(csi_rxc_hs_en_o), 
		.mipi_rx_dat_hs_en_o	(csi_rxd0_hs_en_o), 
		.mipi_rx_clk_term_en_o	(csi_rxc_hs_term_en_o), 
		.mipi_rx_dat_term_en_o	(csi_rxd0_hs_term_en_o), 
		
		.CLK				(w_csi_rx_clk), 
		.VSYNC			(w_csi_rx_vsync0), 
		.HSYNC			(w_csi_rx_hsync0), 
		.DE				(w_csi_rx_dvalid), 
		.DAT				(w_csi_rx_data_rel_raw)
	);
	assign w_csi_rx_data = {2{w_csi_rx_data_rel_raw[47:40], w_csi_rx_data_rel_raw[35:28], w_csi_rx_data_rel_raw[23:16], w_csi_rx_data_rel_raw[11:4]}};
	assign {csi_rxd3_hs_en_o, csi_rxd2_hs_en_o, csi_rxd1_hs_en_o} = {3{csi_rxd0_hs_en_o}};
	assign {csi_rxd3_hs_term_en_o, csi_rxd2_hs_term_en_o, csi_rxd1_hs_term_en_o} = {3{csi_rxd0_hs_term_en_o}};
	assign wr_data = {w_csi_rx_data_rel_raw[39:32], w_csi_rx_data_rel_raw[29:22],w_csi_rx_data_rel_raw[19:12], w_csi_rx_data_rel_raw[9:2]} ;

`else
	
	csi_rx mipi_rx_0(
    .reset_n                           (rstn_sys                  ),
    .clk                               (w_csi_rx_clk              ), // [FIX] 已改为 clk_pixel
 
    .reset_byte_HS_n                   (rstn_sys                  ),
    .clk_byte_HS                       (csi_rxc_i                 ),
    
 
    
    .reset_pixel_n                     (r_reset_pixen_n           ),//rstn_sys),
    .clk_pixel                         (w_csi_rx_clk              ), // [FIX] 已改为 clk_pixel
    // .Rx_LP_CLK_P                       (    csi_rxc_lp_n_i         ),
    // .Rx_LP_CLK_N                       (    csi_rxc_lp_p_i        ),
    .Rx_LP_CLK_P                       (csi_rxc_lp_p_i         ),
    .Rx_LP_CLK_N                       (csi_rxc_lp_n_i         ),

    .Rx_HS_enable_C                    (csi_rxc_hs_en_o           ),
    .LVDS_termen_C                     (csi_rxc_hs_term_en_o      ),
		
		//	Lane inversion affects HS & LP data only.
		.Rx_LP_D_P                         ({CSI_RXD_INV[3] ? csi_rxd3_lp_n_i : csi_rxd3_lp_p_i, CSI_RXD_INV[2] ? csi_rxd2_lp_n_i : csi_rxd2_lp_p_i, CSI_RXD_INV[1] ? csi_rxd1_lp_n_i : csi_rxd1_lp_p_i, CSI_RXD_INV[0] ? csi_rxd0_lp_n_i : csi_rxd0_lp_p_i}),
    .Rx_LP_D_N                         ({CSI_RXD_INV[3] ? csi_rxd3_lp_p_i : csi_rxd3_lp_n_i, CSI_RXD_INV[2] ? csi_rxd2_lp_p_i : csi_rxd2_lp_n_i, CSI_RXD_INV[1] ? csi_rxd1_lp_p_i : csi_rxd1_lp_n_i, CSI_RXD_INV[0] ? csi_rxd0_lp_p_i : csi_rxd0_lp_n_i}),
 
    .Rx_HS_D_0                         ((CSI_RXD_INV[0] ? 8'hFF : 8'h00) ^ csi_rxd0_hs_i),
    .Rx_HS_D_1                         ((CSI_RXD_INV[1] ? 8'hFF : 8'h00) ^ csi_rxd1_hs_i),
    .Rx_HS_D_2                         ((CSI_RXD_INV[2] ? 8'hFF : 8'h00) ^ csi_rxd2_hs_i),
  
 
    .Rx_HS_D_3                         ((CSI_RXD_INV[3] ? 8'hFF : 8'h00) ^ csi_rxd3_hs_i),
    .Rx_HS_D_4                         (                          ),
    .Rx_HS_D_5                         (                          ),
    .Rx_HS_D_6                         (                          ),
  
    .Rx_HS_D_7                         (                          ),
		
    .Rx_HS_enable_D                    ({csi_rxd3_hs_en_o, csi_rxd2_hs_en_o, csi_rxd1_hs_en_o, csi_rxd0_hs_en_o}),
    .LVDS_termen_D                     ({csi_rxd3_hs_term_en_o, csi_rxd2_hs_term_en_o, csi_rxd1_hs_term_en_o, csi_rxd0_hs_term_en_o}),
    .fifo_rd_enable                    ({csi_rxd3_fifo_rd_o, csi_rxd2_fifo_rd_o, csi_rxd1_fifo_rd_o, csi_rxd0_fifo_rd_o}),
    .fifo_rd_empty                     ({csi_rxd3_fifo_empty_i, csi_rxd2_fifo_empty_i, csi_rxd1_fifo_empty_i, csi_rxd0_fifo_empty_i}),
    .DLY_enable_D                      (                           ),
    .DLY_inc_D                         (                          ),
    .u_dly_enable_D                    (0                        ),
    .u_dly_inc_D                       (                          ),
		
    .vsync_vc1                         (                          ),
    .vsync_vc15                        (                          ),
    .vsync_vc12                        (                          ),
    .vsync_vc9                         (                          ),
    
	.vsync_vc7                         (                          ),
    .vsync_vc14                        (                          ),
 
    .vsync_vc13                        (                          ),
    .vsync_vc11                        (                          ),
    .vsync_vc10                        (                          ),
    .vsync_vc8                         (                          ),
    .vsync_vc6                         (                          ),
    .vsync_vc4                         (                          ),
    .vsync_vc0                         (w_csi_rx_vsync0           ),
    .vsync_vc5                         (                          ),
    .vsync_vc3                         (                          ),
    .vsync_vc2                         (                          ),
	
    .irq                               (                          ),
		
    .pixel_data_valid                  (w_csi_rx_dvalid           ),
    .pixel_data                        (w_csi_rx_data             ),
    .pixel_per_clk                     (                          ),
    .datatype                          (data_typer                ),
    .shortpkt_data_field               (                          ),
    .word_count                        (                          ),
    .vcx                               (                          ),
    .vc                                (                          ),
    .hsync_vc3                         (                          ),
    .hsync_vc2                         (                          ),
    .hsync_vc8                         (                          ),
    .hsync_vc12                        (                          ),
    .hsync_vc7                         (                          ),
    .hsync_vc10                        (                          ),
    .hsync_vc1                         (                          ),
    .hsync_vc0                         (w_csi_rx_hsync0           ),
    .hsync_vc13                        (                          ),
    .hsync_vc4                         (                          ),
    .hsync_vc11                        (                          ),
    .hsync_vc6                         (                          ),
    .hsync_vc9                         (                          ),
    .hsync_vc15                        (                          ),
    .hsync_vc14                        (                          ),
    .hsync_vc5                         (                          ),
		
    .axi_clk                           (clk_sys                   ), // AXI-Lite 寄存器时钟, 
  
    .axi_reset_n                       (rstn_sys                  ),
		
    .axi_awaddr                        (r_axi_addr                ),
    .axi_awvalid                       ((r_axi_sel == CSI_AXILITE_ID) && r_axi_awvalid),
    .axi_awready                       (w_csi_axi_awready         ),
	
    .axi_wvalid                        ((r_axi_sel == CSI_AXILITE_ID) && r_axi_wvalid),
    .axi_wdata                         (r_axi_wdata               ),
    .axi_wready                        (w_csi_axi_wready          ),
	
    .axi_bvalid                        (                          ),
    .axi_bready                        (1                         ),
		
    .axi_araddr                        (r_axi_addr                ),
    .axi_arvalid                       ((r_axi_sel == CSI_AXILITE_ID) && r_axi_arvalid),
    .axi_arready                       (w_csi_axi_arready         ),
		
    .axi_rready                        (1                         ),
    .axi_rvalid                        (w_csi_axi_rvalid          ),
    .axi_rdata                         (w_csi_axi_rdata           ) 
		
    );
	assign wr_data = {w_csi_rx_data[39:32], w_csi_rx_data[29:22],w_csi_rx_data[19:12], w_csi_rx_data[9:2]} ;

`endif 
	assign csi_rxd0_rst_o = rst_sys; 
	assign csi_rxd1_rst_o = rst_sys; 
	assign csi_rxd2_rst_o = rst_sys;
	assign csi_rxd3_rst_o = rst_sys;
	
	
	//	Output LED
	reg 	[5:0]		r_csi_fv_o = 0; 
	reg 	[1:0] 	r_csi_rx_vsync0_in = 0;
	always @(posedge w_csi_rx_clk) begin
		r_csi_rx_vsync0_in <= {r_csi_rx_vsync0_in, w_csi_rx_vsync0}; 
		r_csi_fv_o <= r_csi_fv_o + ((r_csi_rx_vsync0_in == 2'b01) ? 1 : 0);
	end
	assign led_o[4] = r_csi_fv_o[5];



wire [10:0] cnt_pixel;
wire [10:0] cnt_row;
	Row_Line_Counter  u_Row_Line_Counter_RAW ( // 重命名以区分
    .Data_clk                          (w_csi_rx_clk               ),
    .Data_rst_n                        (rstn_sys             ),
    .Data_vsync                        (w_csi_rx_vsync0         ),
    .Data_hsync                        (w_csi_rx_hsync0         ),//用于统计行
    .Data_valid                        (w_csi_rx_dvalid         ),//用于统计每一行的像素

    .cnt_pixel                         (cnt_pixel   [10:0]),
    .cnt_row                           (cnt_row     [10:0]) 
);
// =========================================================================================================================================
// data 32 to 8
// ========================================================================================================================================= 

//c1
// assign wr_data = {w_csi_rx_data[9:2], w_csi_rx_data[19:12], w_csi_rx_data[29:22], w_csi_rx_data[39:32]} ;
	assign wr_en = w_csi_rx_hsync0 && w_csi_rx_dvalid;

always@(posedge w_csi_rx_clk or negedge rstn_sys)
begin
	if(!rstn_sys)
		begin
			rd_en   <=  'd0 ;
		end
	else if(pixel_cnt == 1279)
		begin
			rd_en   <=  'd0 ;
		end
	else if(rd_count >=1280)
		begin
			rd_en   <=  1;
		end
	else
		begin
			rd_en   <=  rd_en ;
		end
end
always@(posedge w_csi_rx_clk or negedge rstn_sys)
begin
	if(!rstn_sys)
		begin
			pixel_cnt   <=  'd0 ;
		end
	else if(pixel_cnt == 1279)
		begin
			pixel_cnt   <=  'd0 ;
		end
	else if(rd_en)
		begin
			pixel_cnt   <=  pixel_cnt + 1 ;
		end
	else
		begin
			pixel_cnt   <=  'd0 ;
		end
end
//c2
afifo_w32r8_reshape u_afifo_w32r8_reshape
(
	.full_o                            (                          ),
    .rst_busy                          (                          ),
	.empty_o                           (empty_o                   ),
    .a_rst_i                           (~rstn_sys                 ),
   
    .wr_clk_i                          (w_csi_rx_clk                ),
    .wdata                             (wr_data                   ),
    .wr_en_i                           (wr_en                     ),
    .wr_datacount_o                    (                           ),
    
    .rd_clk_i                          (w_csi_rx_clk                ),
    .rd_en_i                           (rd_en                     ),
    .rdata                             (rd_data                   ),
    .rd_datacount_o                    (rd_count                  )
);
//c3
wire                                    delay_vsync                ;
	delay_reg #(.delay_level(1280),.reg_width(1)) DR0(
    .clk                               (w_csi_rx_clk                ),
    .rst                               (~rstn_sys                   ),
    .din                               (w_csi_rx_vsync0      ),

    .dout                              (delay_vsync               ) 
);
	assign prepare_vsync = delay_vsync;
assign prepare_valid = rd_en;
assign prepare_data = rd_data;
	// =========================================================================================================================================
// XYCrop
// ========================================================================================================================================= 
	wire			XYCrop_frame_vsync; 
	wire			XYCrop_frame_href;
	wire			XYCrop_frame_de;
	wire	[7:0]	XYCrop_frame_Gray;
	Sensor_Image_XYCrop
    #(
    .IMAGE_HSIZE_SOURCE                (1280 / CSI_STRB_WIDTH     ),
    .IMAGE_VSIZE_SOURCE                (960                       ),
    .IMAGE_HSIZE_TARGET                (1280 / CSI_STRB_WIDTH     ),
    .IMAGE_YSIZE_TARGET                (720                       ),
    .PIXEL_DATA_WIDTH                  (8                        ) //	32		 )
    )
    
 
    

u_Sensor_Image_XYCrop
    (
		//	globel clock
    .clk                               (w_csi_rx_clk              ),//	image pixel clock
    .rst_n                             (rstn_sys                  ),//	system reset
		
		//CMOS Sensor interface
    .image_in_vsync                    (prepare_vsync           ),//H : Data Valid; L : Frame Sync(Set it by register)
    .image_in_href                     (prepare_valid       ),//H : Data vaild, L : Line Sync
  
    .image_in_de                       (prepare_valid            ),//H : Data Enable, L : Line Sync
    .image_in_data                     (prepare_data),//8 bits cmos data input
		
    .image_out_vsync                   (XYCrop_frame_vsync        ),//H : Data Valid; L : Frame Sync(Set it by register)
    .image_out_href                    (XYCrop_frame_href         ),//H : Data vaild, L : Line Sync
    .image_out_de                      (XYCrop_frame_de           ),//H : Data Enable, L : Line Sync
  
    .image_out_data                    (XYCrop_frame_Gray         ) //8 bits cmos data input	
    );
	reg			r_XYCrop_frame_vsync = 0;
	reg			r_XYCrop_frame_href = 0;
	reg			r_XYCrop_frame_de = 0;
	reg	[63:0]	r_XYCrop_frame_Gray = 0;
	
	always @(posedge w_csi_rx_clk) begin
		r_XYCrop_frame_vsync <= XYCrop_frame_vsync;
		r_XYCrop_frame_href <= XYCrop_frame_href;
		r_XYCrop_frame_de <= XYCrop_frame_de;
		r_XYCrop_frame_Gray <= XYCrop_frame_Gray;
	end
	
	//	Data Write Assignment
	wire			cmos_frame_vsync = r_XYCrop_frame_vsync;
	//  cmos frame data vsync valid signal
	wire			cmos_frame_href = r_XYCrop_frame_href && r_XYCrop_frame_de;
	//  cmos frame data href vaild  signal
	wire	[7:0]	cmos_frame_Gray = r_XYCrop_frame_Gray;
	//c1 crop data
wire                                    crop_vsync                 ;
wire                                    crop_valid                 ;
wire                   [   7:0]         crop_data                  ;
	assign crop_vsync = r_XYCrop_frame_vsync;
assign crop_valid = cmos_frame_href ;
assign crop_data = cmos_frame_Gray;
	// =========================================================================================================================================
// P1_Bayer2rgb
// ========================================================================================================================================= 
wire 			w_rgb_vsync, w_rgb_hsync, w_rgb_href; 
wire 	[7:0] 	w_rgb_r, w_rgb_g, w_rgb_b;
	wire [11:0] cnt_bayer_pixel;
	wire [11:0] cnt_bayer_row  ;
VIP_RAW8_RGB888 #(.IMG_HDISP(1280), .IMG_VDISP(720)) ori_bayer2rgb (
    .clk                               (w_csi_rx_clk                ),//cmos video pixel clock
    .rst_n                             (rstn_sys                  ),//global reset
	
    .mirror                            (2'b11                     ),

	//CMOS YCbCr444 data output
    .per_frame_vsync                   (crop_vsync                ),//Prepared Image data vsync valid signal. Reset on falling edge.
    .per_frame_hsync                   (crop_valid                ),//Prepared Image data href vaild  signal
    .per_frame_href                    (crop_valid                ),//Prepared Image data href vaild  signal
    .per_img_RAW                       (crop_data                 ),//Prepared Image data 8 Bit RAW Data

    .post_frame_vsync                  (w_rgb_vsync               ),//Processed Image data vsync valid signal
    .post_frame_hsync                  (w_rgb_hsync               ),//Processed Image data href vaild  signal
    .post_frame_href                   (w_rgb_href                ),//Processed Image data href vaild signal
    .post_img_red                      (w_rgb_r                   ),//Prepared Image green data to be processed
    .post_img_green                    (w_rgb_g                   ),//Prepared Image green data to be processed
    .post_img_blue                     (w_rgb_b                   ) //Prepared Image blue data to be processed
);
	// =========================================================================================================================================
// P1.5_Generate Counters for Vignetting
// (Generates counters synchronous with Demosaic output)
// =========================================================================================================================================
Row_Line_Counter u_Row_Line_Counter_RGB (
    .Data_clk                          (w_csi_rx_clk               ),
    .Data_rst_n                        (rstn_sys                   ),
    .Data_vsync                        (w_rgb_vsync                ), // Input from Demosaic
    .Data_hsync                        (w_rgb_hsync                ), // Input from Demosaic
    .Data_valid                        (w_rgb_href                 ), // Input from Demosaic

    .cnt_pixel                         (w_rgb_h_cnt                ),
    .cnt_row                           (w_rgb_v_cnt                )
);
	// =========================================================================================================================================
// P1.6_Vignetting Correction (User Module)
// =========================================================================================================================================
vignetting_correction #(
    .IMG_WIDTH     (1280),
    .IMG_HEIGHT    (720),
    .DATA_WIDTH    (8),
    .K_SHIFT       (12) // Per user's file
) u_vignetting_correction (
    .clk           (w_csi_rx_clk),
    .rst_n         (rstn_sys),
    
    // Input from Demosaic & RGB Counters
    .vsync_i       (w_rgb_vsync),
    .valid_i       (w_rgb_href), // 'valid_i' maps to 'href'
    .r_i           (w_rgb_r),
    .g_i           (w_rgb_g),
    .b_i           (w_rgb_b),
    .h_cnt         (w_rgb_h_cnt),
    .v_cnt         (w_rgb_v_cnt),

    // Output to AE Stats and MWB
 
    .vsync_o       (w_vignette_vsync),
    .valid_o       (w_vignette_valid),
    .r_o           (w_vignette_r),
    .g_o           (w_vignette_g),
    .b_o           (w_vignette_b)
);
	// =========================================================================================================================================
// P1.7_Denoise (降噪模块) - [新插入]
// =========================================================================================================================================
// 为降噪模块的输出定义新的线网
wire w_denoise_vsync, w_denoise_valid;
wire [7:0] w_denoise_r, w_denoise_g, w_denoise_b;
	isp_denoise #(
    .DATA_WIDTH (8)
) u_isp_denoise (
    .clk           (w_csi_rx_clk),
    .rst_n         (rstn_sys),
    
    // Input from Vignetting
    .vsync_i       (w_vignette_vsync),
    .valid_i       (w_vignette_valid),
    .r_i           (w_vignette_r),
    .g_i           (w_vignette_g),
 
    .b_i           (w_vignette_b),

    // Output to AE Stats and MWB
    .vsync_o       (w_denoise_vsync),
    .valid_o       (w_denoise_valid),
    .r_o           (w_denoise_r),
    .g_o           (w_denoise_g),
    .b_o           (w_denoise_b)
);
	// =========================================================================================================================================
// AE (自动曝光) 统计模块
// =========================================================================================================================================
ae_statistics u_ae_statistics (
    .clk                (w_csi_rx_clk),     // [FIX] 使用 ISP 时钟 (clk_pixel)
    .rst_n              (rstn_sys),
    
    // [修改] 输入来自 Denoise 模块 (原为 Vignetting)
    .in_vsync           (w_denoise_vsync),
    .in_href            (w_denoise_valid),
    .in_r               (w_denoise_r),
    .in_g               (w_denoise_g),
    .in_b               (w_denoise_b),

	// 输出至 AE Control
    .avg_brightness_out (w_avg_brightness),
    .frame_done_out     (w_frame_done)
);
	// =========================================================================================================================================
// AE (自动曝光) 控制模块
// =========================================================================================================================================
ae_control u_ae_control (
    .clk                (w_csi_rx_clk),     // [FIX] 使用 ISP 时钟 (clk_pixel)
    .rst_n              (rstn_sys),
    
    // 输入来自 AE Statistics
    .frame_done         (w_frame_done),
    .avg_brightness     (w_avg_brightness),
    
    // 输出至 P2_MWB 模块
	.ae_gain_q8_8       (w_ae_gain_q8_8)
);

// ========================================================================================================================================= 
// [新插入] AWB 自动白平衡线网
// ========================================================================================================================================= 
wire [31:0] w_awb_r_sum;
wire [31:0] w_awb_g_sum;
wire [31:0] w_awb_b_sum;
wire        w_awb_frame_done;
wire [15:0] w_awb_r_gain;
wire [15:0] w_awb_g_gain;
wire [15:0] w_awb_b_gain;

// ========================================================================================================================================= 
// P2_MWB (手动白平衡) + DAE (数字自动曝光)
// ========================================================================================================================================= 
wire                                    rgb_vsync                  ;
wire                                    rgb_valid                  ;
wire                   [  23:0]         rgb_data                   ;
// 步骤 1: 减去黑电平 (修复 "发灰")
// [时序修复] 增加 1 拍寄存器
reg [7:0] p1_r, p1_g, p1_b;
reg p1_vsync, p1_hsync, p1_href;
	localparam BLACK_LEVEL = 16;

always @(posedge w_csi_rx_clk or negedge rstn_sys) begin
	if(!rstn_sys) begin
		p1_r <= 0;
		p1_g <= 0; p1_b <= 0;
		p1_vsync <= 0; p1_hsync <= 0; p1_href <= 0;
	end else begin
		// [修改] 输入来自 Denoise 模块 (原为 Vignetting)
		p1_vsync <= w_denoise_vsync;// 来自 Denoise
		p1_hsync <= 1'b0;
		// HSync is not used downstream
		p1_href  <= w_denoise_valid;// 来自 Denoise
		p1_r     <= (w_denoise_r > BLACK_LEVEL) ? (w_denoise_r - BLACK_LEVEL): 0;
		p1_g     <= (w_denoise_g > BLACK_LEVEL) ? (w_denoise_g - BLACK_LEVEL): 0;
		p1_b     <= (w_denoise_b > BLACK_LEVEL) ? (w_denoise_b - BLACK_LEVEL): 0;
	end
end

// =========================================================================================================================================
// [新插入] AWB (自动白平衡) 统计模块
// =========================================================================================================================================
awb_statistics u_awb_statistics (
    .clk            (w_csi_rx_clk),     // ISP 时钟
    .rst_n          (rstn_sys),
    
    // 输入来自 P1 (Black Level 补正后)
    .in_vsync       (p1_vsync),
    .in_valid       (p1_href),
    .in_r           (p1_r),
    .in_g           (p1_g),
    .in_b           (p1_b),

    // 输出至 AWB Control
    .r_sum_out      (w_awb_r_sum),
    .g_sum_out      (w_awb_g_sum),
    .b_sum_out      (w_awb_b_sum),
    .frame_done_out (w_awb_frame_done)
);

// =========================================================================================================================================
// [新插入] AWB (自动白平衡) 控制模块
// =========================================================================================================================================
awb_control u_awb_control (
    .clk            (w_csi_rx_clk),     // ISP 时钟
    .rst_n          (rstn_sys),
    
    // 输入来自 AWB Statistics
    .frame_done_i   (w_awb_frame_done),
    .r_sum_i        (w_awb_r_sum),
    .g_sum_i        (w_awb_g_sum),
    .b_sum_i        (w_awb_b_sum),

    // 输出至 P2 (Gain Application stage)
    .r_gain_o       (w_awb_r_gain), 
    .g_gain_o       (w_awb_g_gain), 
    .b_gain_o       (w_awb_b_gain)
);

// 步骤 2: 应用数字 AE 增益 (来自 ae_control 模块)
// (p1_r * w_ae_gain_q8_8) >> 8
wire [23:0] ae_r_mult = p1_r * w_ae_gain_q8_8;
// 8b * 16b (Q8.8) = 24b (Q16.8)
wire [23:0] ae_g_mult = p1_g * w_ae_gain_q8_8;
wire [23:0] ae_b_mult = p1_b * w_ae_gain_q8_8;

// 右移8位，变回整数域 (最大值 255 * 4.0 = 1020, 需要10+ bits)
wire [15:0] ae_r = ae_r_mult[23:8];
wire [15:0] ae_g = ae_g_mult[23:8];
wire [15:0] ae_b = ae_b_mult[23:8];

// [替换] 步骤 3: 应用自动白平衡(AWB)和自动曝光(AE)增益
// ae_r, ae_g, ae_b 已经是 AE 增益应用后的结果 (16-bit 整数)
// w_awb_..._gain (来自 AWB) 是 Q8.8 格式
//
// 最终增益 = (ae_r * w_awb_r_gain) >> 8
//
wire [31:0] w_rgb_r_mult = ae_r * w_awb_r_gain; // 16b * 16b(Q8.8) = 32b(Q16.8)
wire [31:0] w_rgb_g_mult = ae_g * w_awb_g_gain; // 16b * 16b(Q8.8) = 32b(Q16.8)
wire [31:0] w_rgb_b_mult = ae_b * w_awb_b_gain; // 16b * 16b(Q8.8) = 32b(Q16.8)

// [替换] 步骤 4: 移位 + 饱和处理 (组合逻辑)
// 检查高位 [31:16] 是否有溢出 (即 > 255)
// 结果位于 [15:8]
wire [7:0] mwb_r = |w_rgb_r_mult[31:16] ? 8'hFF : w_rgb_r_mult[15: 8];
wire [7:0] mwb_g = |w_rgb_g_mult[31:16] ? 8'hFF : w_rgb_g_mult[15: 8];
wire [7:0] mwb_b = |w_rgb_b_mult[31:16] ? 8'hFF : w_rgb_b_mult[15: 8];

// 步骤 5: 寄存器输出 (总共 2 拍延迟)
reg [7:0] p2_r, p2_g, p2_b;
reg p2_vsync, p2_hsync, p2_href;
	always @(posedge w_csi_rx_clk or negedge rstn_sys) begin
	if(!rstn_sys) begin
		p2_r <= 0; p2_g <= 0; p2_b <= 0;
		p2_vsync <= 0;
		p2_hsync <= 0; p2_href <= 0;
	end else begin
		p2_vsync <= p1_vsync;
		p2_hsync <= p1_hsync;
		p2_href  <= p1_href;
		p2_r     <= mwb_r;
		p2_g     <= mwb_g;
		p2_b     <= mwb_b;
	end
end

// =========================================================================================================================================
// [已移除] P3_Sharpening (锐化)
// =========================================================================================================================================
/*
... (sharpen code commented out) ...
*/

// =========================================================================================================================================
// [已移除] P4_Gamma 校正模块
// =========================================================================================================================================
/*
... (gamma code commented out) ...
*/

// =========================================================================================================================================
// [新插入] P5_Video Delay (流水线延时)
// =========================================================================================================================================
// 在这里插入一个 5 拍的延迟, 演示功能
// p2_... 寄存器是 ISP 的最终输出
// rgb_... 线网是 DDR 控制器的输入
// p2_href 是 'valid' 信号
isp_video_delay #(
    .STAGES(5),         // <--- 在这里设置延迟拍数
    .DATA_WIDTH(24)     // R(8) + G(8) + B(8) = 24
) u_isp_video_delay (
    .clk        (w_csi_rx_clk),
    .rst_n      (rstn_sys),
    
    // Input Stream (from p2 registers)
    .vsync_i    (p2_vsync),
    .valid_i    (p2_href),
    .data_i     ({p2_r, p2_g, p2_b}),
    
    // Output Stream (to DDR controller)
    .vsync_o    (rgb_vsync), // 连接到 rgb_vsync
    .valid_o    (rgb_valid), // 连接到 rgb_valid
    .data_o     (rgb_data)   // 连接到 rgb_data
);

// [修改] 原先的 assign 语句已被上面的模块替换
// assign rgb_vsync = p2_vsync;
// assign rgb_valid = p2_href;
// assign rgb_data  = {p2_r, p2_g, p2_b};

// =========================================================================================================================================
// DDR Ctrl
// ========================================================================================================================================= 
	wire                            lcd_de;
	wire                            lcd_hs;
	wire                            lcd_vs;
	wire 					  lcd_request;
	wire            [7:0]           lcd_red, lcd_red2;
	wire            [7:0]           lcd_green, lcd_green2;
	wire            [7:0]           lcd_blue, lcd_blue2;
	wire            [31:0]          lcd_data;
	assign w_ddr3_awid = 0;
	assign w_ddr3_wid = 0; 
	
	wire 			w_wframe_vsync; 
	wire 	[7:0] 	w_axi_tp;
	axi4_ctrl #(.C_RD_END_ADDR(1280 * 720 *4), .C_W_WIDTH(32), .C_R_WIDTH(32), .C_ID_LEN(4)) u_axi4_ctrl (

		.axi_clk        (w_ddr3_ui_clk            ),
		.axi_reset      (w_ddr3_ui_rst            ),

		.axi_awaddr     (w_ddr3_awaddr       ),
		.axi_awlen      (w_ddr3_awlen        ),
		.axi_awvalid    (w_ddr3_awvalid      ),
		.axi_awready    (w_ddr3_awready      ),

		.axi_wdata      (w_ddr3_wdata          ),
		.axi_wstrb      (w_ddr3_wstrb        ),
		.axi_wlast      (w_ddr3_wlast        ),
		.axi_wvalid     (w_ddr3_wvalid       ),
		.axi_wready     (w_ddr3_wready       ),

		.axi_bid        (0          ),
		.axi_bresp      (0        ),
		.axi_bvalid     (1        ),

		.axi_arid       (w_ddr3_arid         ),
		.axi_araddr     (w_ddr3_araddr       ),
		.axi_arlen      (w_ddr3_arlen        ),
		.axi_arvalid    (w_ddr3_arvalid      ),
		.axi_arready    (w_ddr3_arready      ),

		.axi_rid        (w_ddr3_rid          ),
		.axi_rdata      (w_ddr3_rdata         ),
		.axi_rresp      (0        ),
		.axi_rlast      (w_ddr3_rlast        ),
		.axi_rvalid     (w_ddr3_rvalid       ),
		.axi_rready     (w_ddr3_rready       ),

		// wframe_... 端口现在接收来自 isp_video_delay 模块的延迟后数据
		.wframe_pclk    (w_csi_rx_clk          ), // [FIX] 已改为 clk_pixel
		.wframe_vsync   (rgb_vsync), //w_wframe_vsync   ),		//	Writter VSync. Flush on rising edge. Connect to EOF.
		.wframe_data_en (rgb_valid   ),
		.wframe_data    ({8'b0,rgb_data} ),
		
		.rframe_pclk    (clk_pixel            ), // 74.25MHz
		.rframe_vsync   (~lcd_vs             ),		//	Reader VSync. Flush on rising edge. Connect to ~EOF.
		.rframe_data_en (lcd_request             ),
		.rframe_data    (lcd_data           ),
		
		.tp_o 		(w_axi_tp)
	);
	assign led_o[3:0] = w_axi_tp;
// =========================================================================================================================================
// lcd_driver
// ========================================================================================================================================= 
	
wire [11:0] x_pos;
wire [11:0] y_pos;
wire [23:0] char_data;
wire data_enable;
	wire data_enable2;


    lcd_driver u_lcd_driver
    (
	    //  global clock
    .clk                               (clk_pixel                 ),
    .rst_n                             (rstn_pixel                ),
	    
	    //  lcd interface
    .lcd_dclk                          (                          ),
    .lcd_blank                         (                          ),
    .lcd_sync                          (                          ),
    .lcd_request                       (lcd_request               ),//	Request data 1 cycle ahead.
    .lcd_hs                            (lcd_hs                    ),
    .lcd_vs                            (lcd_vs                    ),
    .lcd_en                            (lcd_de                    ),
   
 
	 
    .lcd_rgb                           ({lcd_red2,lcd_green2,lcd_blue2, lcd_red,lcd_green,lcd_blue}),
	    
	    //  user interface
    .lcd_data                          ({lcd_data[23:0] ,lcd_data[23:0]}),
    .lcd_xpos                          (x_pos                     ),
    .lcd_ypos                          (y_pos                     ) 
    );
	// wire [23:0] hdmi_data = (data_enable||data_enable2)? char_data : {lcd_red,lcd_green,lcd_blue}    ;
	wire [23:0] hdmi_data =  {lcd_red,lcd_green,lcd_blue}    ;
	// =========================================================================================================================================
// BoundCrop
// ========================================================================================================================================= 

wire                                    w_rgb_vs_o, w_rgb_hs_o, w_rgb_de_o;
wire                   [  23:0]         w_rgb_data_o               ;
	FrameBoundCrop #(.SKIP_ROWS(4),.SKIP_COLS(2),.TOTAL_ROWS(720),.TOTAL_COLS(1280)) inst_FrameCrop(
    .clk_i                             (clk_pixel                 ),
    .rst_i                             (~rstn_pixel               ),
	
    .hs_i                              (lcd_hs              ),
    .vs_i                              (lcd_vs              ),
    
 

    .de_i                              (lcd_de              ),
    .data_i                            (hdmi_data            ),
	
    .vs_o                              (w_rgb_vs_o                ),
    .hs_o                              (w_rgb_hs_o                ),
    .de_o                              (w_rgb_de_o                ),
    .data_o                            (w_rgb_data_o              ) 

);
	// =========================================================================================================================================
// HDMI Interface
// ========================================================================================================================================= 
	assign hdmi_txd0_rst_o = rst_pixel; 
	assign hdmi_txd1_rst_o = rst_pixel; 
	assign hdmi_txd2_rst_o = rst_pixel;
	assign hdmi_txc_rst_o = rst_pixel;
	
	assign hdmi_txd0_oe = 1'b1; 
	assign hdmi_txd1_oe = 1'b1; 
	assign hdmi_txd2_oe = 1'b1; 
	assign hdmi_txc_oe = 1'b1;
	//-------------------------------------
	//Digilent HDMI-TX IP Modified by CB elec.
	
	// [!! 修正 !!] 将模块名从 'rgb2dii' 改回 'rgb2dvi'
    rgb2dvi #(.ENABLE_OSERDES(0)) u_rgb2dvi
    (
    .oe_i                              (1                         ),//	Always enable output
    .bitflip_i                         (4'b0000                   ),//	Reverse clock & data lanes.
		
    .aRst                              (1'b0                      ),
    .aRst_n                            (1'b1                      ),
		
    .PixelClk                          (clk_pixel                 ),//pixel clk = 74.25M
    .SerialClk                         (                          ),//pixel clk *5 = 371.25M
		
    .vid_pVSync                        (w_rgb_vs_o                    ),
    .vid_pHSync                        (w_rgb_hs_o                    ),
    .vid_pVDE                          (w_rgb_de_o                    ),
    .vid_pData                         (w_rgb_data_o),
		
    .txc_o                             (hdmi_txc_o                ),
    .txd0_o                            (hdmi_txd0_o               ),
    .txd1_o                            (hdmi_txd1_o               ),
    .txd2_o                            (hdmi_txd2_o               ) 
    );
		
endmodule