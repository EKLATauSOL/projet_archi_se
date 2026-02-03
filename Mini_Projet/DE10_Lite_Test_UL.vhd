library ieee;
use ieee.std_logic_1164.all;

entity DE10_Lite_Test_UL is
    port (
        MAX10_CLK1_50 : in  std_logic;                     -- PIN_P11
        KEY           : in  std_logic_vector(1 downto 0);  -- PIN_B8 (KEY0)
        LEDR          : out std_logic_vector(9 downto 0);  -- LEDR[9..0]
        GPIO          : inout std_logic_vector(35 downto 0) -- Headers GPIO (JP1)
    );
end entity;

architecture rtl of DE10_Lite_Test_UL is

    component nios2_system is
        port (
            clk_clk                           : in  std_logic := 'X'; -- clk
            reset_reset_n                     : in  std_logic := 'X'; -- reset_n
            telemetre_us_avalon_trig          : out std_logic;
            telemetre_us_avalon_echo          : in  std_logic := 'X';
            telemetre_us_avalon_dist          : out std_logic_vector(9 downto 0)
        );
    end component nios2_system;

begin

    u0 : component nios2_system
        port map (
            clk_clk                           => MAX10_CLK1_50,
            reset_reset_n                     => KEY(0),
            telemetre_us_avalon_dist          => LEDR,
            telemetre_us_avalon_echo          => GPIO(3),
            telemetre_us_avalon_trig          => GPIO(1)
        );

end architecture;
