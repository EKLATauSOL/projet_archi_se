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

    component telemetre_us is
        port (
            clk     : in  std_logic;
            rst_n   : in  std_logic;
            echo    : in  std_logic;
            trig    : out std_logic;
            dist_cm : out std_logic_vector(9 downto 0)
        );
    end component;

begin

    -- Instanciation de l'IP Telemetre
    -- Connexions selon le tableau du sujet :
    -- Rst_n   -> KEY0
    -- CLK     -> MAX10_CLK1_50
    -- Trig    -> GPIO_[1] (PIN_W10)
    -- Echo    -> GPIO_[3] (PIN_W9)
    -- Dist_cm -> LEDR[9..0]

    u0 : telemetre_us
        port map (
            clk     => MAX10_CLK1_50,
            rst_n   => KEY(0),
            echo    => GPIO(3),
            trig    => GPIO(1),
            dist_cm => LEDR
        );

end architecture;
