	nios2_system u0 (
		.clk_clk                           (<connected-to-clk_clk>),                           //                        clk.clk
		.hex3_0_external_connection_export (<connected-to-hex3_0_external_connection_export>), // hex3_0_external_connection.export
		.hex5_4_external_connection_export (<connected-to-hex5_4_external_connection_export>), // hex5_4_external_connection.export
		.key_external_connection_export    (<connected-to-key_external_connection_export>),    //    key_external_connection.export
		.led_external_connection_export    (<connected-to-led_external_connection_export>),    //    led_external_connection.export
		.pwmled_export                     (<connected-to-pwmled_export>),                     //                     pwmled.export
		.reset_reset_n                     (<connected-to-reset_reset_n>),                     //                      reset.reset_n
		.sw_external_connection_export     (<connected-to-sw_external_connection_export>),     //     sw_external_connection.export
		.telemetre_us_avalon_trig          (<connected-to-telemetre_us_avalon_trig>),          //        telemetre_us_avalon.trig
		.telemetre_us_avalon_echo          (<connected-to-telemetre_us_avalon_echo>),          //                           .echo
		.telemetre_us_avalon_dist          (<connected-to-telemetre_us_avalon_dist>)           //                           .dist
	);

