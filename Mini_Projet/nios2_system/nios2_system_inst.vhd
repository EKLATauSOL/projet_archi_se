	component nios2_system is
		port (
			clk_clk                           : in  std_logic                     := 'X';             -- clk
			hex3_0_external_connection_export : out std_logic_vector(31 downto 0);                    -- export
			hex5_4_external_connection_export : out std_logic_vector(15 downto 0);                    -- export
			key_external_connection_export    : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			led_external_connection_export    : out std_logic_vector(9 downto 0);                     -- export
			pwmled_writeresponsevalid_n       : out std_logic;                                        -- writeresponsevalid_n
			reset_reset_n                     : in  std_logic                     := 'X';             -- reset_n
			sw_external_connection_export     : in  std_logic_vector(9 downto 0)  := (others => 'X'); -- export
			telemetre_us_avalon_trig          : out std_logic;                                        -- trig
			telemetre_us_avalon_echo          : in  std_logic                     := 'X';             -- echo
			telemetre_us_avalon_dist          : out std_logic_vector(9 downto 0)                      -- dist
		);
	end component nios2_system;

	u0 : component nios2_system
		port map (
			clk_clk                           => CONNECTED_TO_clk_clk,                           --                        clk.clk
			hex3_0_external_connection_export => CONNECTED_TO_hex3_0_external_connection_export, -- hex3_0_external_connection.export
			hex5_4_external_connection_export => CONNECTED_TO_hex5_4_external_connection_export, -- hex5_4_external_connection.export
			key_external_connection_export    => CONNECTED_TO_key_external_connection_export,    --    key_external_connection.export
			led_external_connection_export    => CONNECTED_TO_led_external_connection_export,    --    led_external_connection.export
			pwmled_writeresponsevalid_n       => CONNECTED_TO_pwmled_writeresponsevalid_n,       --                     pwmled.writeresponsevalid_n
			reset_reset_n                     => CONNECTED_TO_reset_reset_n,                     --                      reset.reset_n
			sw_external_connection_export     => CONNECTED_TO_sw_external_connection_export,     --     sw_external_connection.export
			telemetre_us_avalon_trig          => CONNECTED_TO_telemetre_us_avalon_trig,          --        telemetre_us_avalon.trig
			telemetre_us_avalon_echo          => CONNECTED_TO_telemetre_us_avalon_echo,          --                           .echo
			telemetre_us_avalon_dist          => CONNECTED_TO_telemetre_us_avalon_dist           --                           .dist
		);

