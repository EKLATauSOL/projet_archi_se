
module nios2_system (
	accel_gsensor_cs_n,
	accel_gsensor_sclk,
	accel_gsensor_sdi,
	accel_gsensor_sdo,
	clk_clk,
	hex3_0_external_connection_export,
	hex5_4_external_connection_export,
	key_external_connection_export,
	led_external_connection_export,
	pwmled_output,
	reset_reset_n,
	sw_external_connection_export);	

	output		accel_gsensor_cs_n;
	output		accel_gsensor_sclk;
	inout		accel_gsensor_sdi;
	input		accel_gsensor_sdo;
	input		clk_clk;
	output	[31:0]	hex3_0_external_connection_export;
	output	[15:0]	hex5_4_external_connection_export;
	input	[1:0]	key_external_connection_export;
	output	[9:0]	led_external_connection_export;
	output		pwmled_output;
	input		reset_reset_n;
	input	[9:0]	sw_external_connection_export;
endmodule
