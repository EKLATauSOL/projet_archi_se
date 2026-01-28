
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_lite_top is
    port (
        -- Clock
        CLOCK_50 : in std_logic;

        -- Keys / Switches
        KEY      : in std_logic_vector(1 downto 0); -- actif bas
        SW       : in std_logic_vector(9 downto 0); -- switches

        -- LEDs
        LED      : out std_logic_vector(9 downto 0);

        -- 7-seg displays (actif bas)
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0);

        -- Accelerometer
        GSENSOR_CS_N : out std_logic;
        GSENSOR_SCLK : out std_logic;
        GSENSOR_SDI  : inout std_logic;
        GSENSOR_SDO  : in  std_logic;
        GSENSOR_INT  : in  std_logic_vector(2 downto 1)
    );
end entity;

architecture rtl of DE10_lite_top is

    ------------------------------------------------------------------
    -- Déclaration du composant Nios II généré par Platform Designer
    ------------------------------------------------------------------
    component nios2_system is
        port (
            clk_clk                           : in  std_logic := 'X';
            hex3_0_external_connection_export : out std_logic_vector(31 downto 0);
            hex5_4_external_connection_export : out std_logic_vector(15 downto 0);
            key_external_connection_export    : in  std_logic_vector(1 downto 0) := (others => 'X');
            led_external_connection_export    : out std_logic_vector(9 downto 0);
            pwmled_output                     : out std_logic;
            reset_reset_n                     : in  std_logic := 'X';
            sw_external_connection_export     : in  std_logic_vector(9 downto 0) := (others => 'X');
            
            -- Accelerometer (Conduit exported as 'accel')
            accel_gsensor_cs_n                : out std_logic;
            accel_gsensor_sclk                : out std_logic;
            accel_gsensor_sdi                 : inout std_logic;
            accel_gsensor_sdo                 : in  std_logic
        );
    end component;

    ------------------------------------------------------------------
    -- Signaux internes
    ------------------------------------------------------------------
    signal reset_n : std_logic;
    signal led_bus : std_logic_vector(9 downto 0);

    signal pwm_led : std_logic;

    signal hex3_0  : std_logic_vector(31 downto 0);
    signal hex5_4  : std_logic_vector(15 downto 0);

begin

    ------------------------------------------------------------------
    -- RESET (actif bas)
    ------------------------------------------------------------------
    reset_n <= KEY(0);

    ------------------------------------------------------------------
    -- Instanciation du processeur Nios II
    ------------------------------------------------------------------
    u0 : nios2_system
        port map (
            clk_clk                           => CLOCK_50,
            reset_reset_n                     => reset_n,

            key_external_connection_export    => KEY,
            sw_external_connection_export     => SW,

            led_external_connection_export    => led_bus,
            pwmled_output                     => pwm_led,

            hex3_0_external_connection_export => hex3_0,
            hex5_4_external_connection_export => hex5_4,
            
            -- Accelerometer connection
            accel_gsensor_cs_n                => GSENSOR_CS_N,
            accel_gsensor_sclk                => GSENSOR_SCLK,
            accel_gsensor_sdi                 => GSENSOR_SDI,
            accel_gsensor_sdo                 => GSENSOR_SDO
        );

    ------------------------------------------------------------------
    -- Connexion physique des LEDs
    ------------------------------------------------------------------
    LED(8 downto 0) <= led_bus(8 downto 0);
    LED(9)          <= pwm_led;

    ------------------------------------------------------------------
    -- Afficheurs HEX (unpacking)
    ------------------------------------------------------------------
    HEX0 <= hex3_0(6 downto 0);
    HEX1 <= hex3_0(14 downto 8);
    HEX2 <= hex3_0(22 downto 16);
    HEX3 <= hex3_0(30 downto 24);

    HEX4 <= hex5_4(6 downto 0);
    HEX5 <= hex5_4(14 downto 8);

end architecture;
