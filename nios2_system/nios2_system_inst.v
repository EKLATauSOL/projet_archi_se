	nios2_system u0 (
		.accel_gsensor_cs_n                (<connected-to-accel_gsensor_cs_n>),                //                      accel.gsensor_cs_n
		.accel_gsensor_sclk                (<connected-to-accel_gsensor_sclk>),                //                           .gsensor_sclk
		.accel_gsensor_sdi                 (<connected-to-accel_gsensor_sdi>),                 //                           .gsensor_sdi
		.accel_gsensor_sdo                 (<connected-to-accel_gsensor_sdo>),                 //                           .gsensor_sdo
		.clk_clk                           (<connected-to-clk_clk>),                           //                        clk.clk
		.hex3_0_external_connection_export (<connected-to-hex3_0_external_connection_export>), // hex3_0_external_connection.export
		.hex5_4_external_connection_export (<connected-to-hex5_4_external_connection_export>), // hex5_4_external_connection.export
		.key_external_connection_export    (<connected-to-key_external_connection_export>),    //    key_external_connection.export
		.led_external_connection_export    (<connected-to-led_external_connection_export>),    //    led_external_connection.export
		.pwmled_output                     (<connected-to-pwmled_output>),                     //                     pwmled.output
		.reset_reset_n                     (<connected-to-reset_reset_n>),                     //                      reset.reset_n
		.sw_external_connection_export     (<connected-to-sw_external_connection_export>)      //     sw_external_connection.export
	);

