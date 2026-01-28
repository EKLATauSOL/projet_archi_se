	component nios2_system is
		port (
			accel_gsensor_cs_n                : out   std_logic;                                        -- gsensor_cs_n
			accel_gsensor_sclk                : out   std_logic;                                        -- gsensor_sclk
			accel_gsensor_sdi                 : inout std_logic                     := 'X';             -- gsensor_sdi
			accel_gsensor_sdo                 : in    std_logic                     := 'X';             -- gsensor_sdo
			clk_clk                           : in    std_logic                     := 'X';             -- clk
			hex3_0_external_connection_export : out   std_logic_vector(31 downto 0);                    -- export
			hex5_4_external_connection_export : out   std_logic_vector(15 downto 0);                    -- export
			key_external_connection_export    : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			led_external_connection_export    : out   std_logic_vector(9 downto 0);                     -- export
			pwmled_output                     : out   std_logic;                                        -- output
			reset_reset_n                     : in    std_logic                     := 'X';             -- reset_n
			sw_external_connection_export     : in    std_logic_vector(9 downto 0)  := (others => 'X')  -- export
		);
	end component nios2_system;

	u0 : component nios2_system
		port map (
			accel_gsensor_cs_n                => CONNECTED_TO_accel_gsensor_cs_n,                --                      accel.gsensor_cs_n
			accel_gsensor_sclk                => CONNECTED_TO_accel_gsensor_sclk,                --                           .gsensor_sclk
			accel_gsensor_sdi                 => CONNECTED_TO_accel_gsensor_sdi,                 --                           .gsensor_sdi
			accel_gsensor_sdo                 => CONNECTED_TO_accel_gsensor_sdo,                 --                           .gsensor_sdo
			clk_clk                           => CONNECTED_TO_clk_clk,                           --                        clk.clk
			hex3_0_external_connection_export => CONNECTED_TO_hex3_0_external_connection_export, -- hex3_0_external_connection.export
			hex5_4_external_connection_export => CONNECTED_TO_hex5_4_external_connection_export, -- hex5_4_external_connection.export
			key_external_connection_export    => CONNECTED_TO_key_external_connection_export,    --    key_external_connection.export
			led_external_connection_export    => CONNECTED_TO_led_external_connection_export,    --    led_external_connection.export
			pwmled_output                     => CONNECTED_TO_pwmled_output,                     --                     pwmled.output
			reset_reset_n                     => CONNECTED_TO_reset_reset_n,                     --                      reset.reset_n
			sw_external_connection_export     => CONNECTED_TO_sw_external_connection_export      --     sw_external_connection.export
		);

