library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Lite_Test_UL is
    port (
        MAX10_CLK1_50 : in  std_logic;                     -- PIN_P11
        KEY           : in  std_logic_vector(1 downto 0);  -- PIN_B8 (KEY0)
        LEDR          : out std_logic_vector(9 downto 0);  -- LEDR[9..0]
        GPIO          : inout std_logic_vector(35 downto 0); -- Headers GPIO (JP1)
        SW            : in    std_logic_vector(9 downto 0);  -- SW[9..0]
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(7 downto 0) -- HEX[5..0]
        );
end entity;

architecture rtl of DE10_Lite_Test_UL is

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

begin

    u0 : component nios2_system
        port map (
            clk_clk                           => MAX10_CLK1_50,
            reset_reset_n                     => KEY(0),
            
            -- Télémètre
            telemetre_us_avalon_trig          => GPIO(1),
            telemetre_us_avalon_echo          => GPIO(3),
            telemetre_us_avalon_dist          => LEDR,  -- Affichage direct de la distance hardware
            
            -- Servomoteur (via PWM0)
            pwmled_writeresponsevalid_n       => GPIO(0),
            
            -- Périphériques standards
            sw_external_connection_export     => SW,
            key_external_connection_export    => KEY,
            led_external_connection_export    => open, -- Connecté mais non utilisé (conflit avec LEDR distance)
            
            -- Afficheurs 7 segments (mappage partiel vers les vecteur 32/16 bits)
            hex3_0_external_connection_export(7 downto 0)   => HEX0,
            hex3_0_external_connection_export(15 downto 8)  => HEX1,
            hex3_0_external_connection_export(23 downto 16) => HEX2,
            hex3_0_external_connection_export(31 downto 24) => HEX3,
            hex5_4_external_connection_export(7 downto 0)   => HEX4,
            hex5_4_external_connection_export(15 downto 8)  => HEX5
        );

end architecture;
