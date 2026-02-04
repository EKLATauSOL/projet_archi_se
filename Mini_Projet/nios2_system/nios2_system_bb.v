
module nios2_system (
	clk_clk,
	hex3_0_external_connection_export,
	hex5_4_external_connection_export,
	key_external_connection_export,
	led_external_connection_export,
	pwmled_export,
	reset_reset_n,
	sw_external_connection_export,
	telemetre_us_avalon_trig,
	telemetre_us_avalon_echo,
	telemetre_us_avalon_dist);	

	input		clk_clk;
	output	[31:0]	hex3_0_external_connection_export;
	output	[15:0]	hex5_4_external_connection_export;
	input	[1:0]	key_external_connection_export;
	output	[9:0]	led_external_connection_export;
	output		pwmled_export;
	input		reset_reset_n;
	input	[9:0]	sw_external_connection_export;
	output		telemetre_us_avalon_trig;
	input		telemetre_us_avalon_echo;
	output	[9:0]	telemetre_us_avalon_dist;
endmodule
