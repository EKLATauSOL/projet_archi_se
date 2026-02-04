library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Lite_Servo_Test is
    port (
        MAX10_CLK1_50 : in  std_logic;                    -- Horloge 50 MHz
        KEY           : in  std_logic_vector(1 downto 0); -- Boutons (actifs bas)
        SW            : in  std_logic_vector(9 downto 0); -- Switches
        LEDR          : out std_logic_vector(9 downto 0); -- LEDs (renommé pour correspondre au QSF)
        GPIO          : out std_logic_vector(35 downto 0); -- GPIO
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of DE10_Lite_Servo_Test is
    signal pwm_signal  : std_logic;
    signal reset_n     : std_logic;
begin
    -- Reset actif bas depuis KEY[0]
    reset_n <= KEY(0);
    
    -- 1. Éteindre les afficheurs 7-segments
    HEX0 <= (others => '1'); HEX1 <= (others => '1'); 
    HEX2 <= (others => '1'); HEX3 <= (others => '1');
    HEX4 <= (others => '1'); HEX5 <= (others => '1');

    -- 2. Feedback visuel direct : Toutes les LEDs suivent tous les switches
    LEDR <= SW;
    
    -- 3. Contrôleur de servomoteur (utilise uniquement les 8 premiers switches)
    i_servo : entity work.servomoteur
        port map (
            clk      => MAX10_CLK1_50,
            reset_n  => reset_n,        -- Reset depuis KEY[0]
            position => SW(7 downto 0), -- Position sur 8 bits
            commande => pwm_signal
        );

    -- 4. Envoi du signal vers la sortie physique PIN_V10 (GPIO[0])
    GPIO(0) <= pwm_signal;
    
    -- 5. Mettre les autres GPIO à '0' pour éviter les états flottants
    GPIO(35 downto 1) <= (others => '0');


end architecture;
