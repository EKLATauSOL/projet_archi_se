library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Lite_Servo_Test is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(1 downto 0); 
        SW       : in  std_logic_vector(9 downto 0);
        LED      : out std_logic_vector(9 downto 0);
        GPIO     : out std_logic_vector(35 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of DE10_Lite_Servo_Test is
    signal pwm_signal  : std_logic;
begin
    -- 1. Éteindre les afficheurs 7-segments
    HEX0 <= (others => '1'); HEX1 <= (others => '1'); 
    HEX2 <= (others => '1'); HEX3 <= (others => '1');
    HEX4 <= (others => '1'); HEX5 <= (others => '1');

    -- 2. Feedback visuel direct : Toutes les LEDs suivent tous les switches
    LED <= SW;
    
    -- 3. Contrôleur de servomoteur (utilise uniquement les 8 premiers switches)
    i_servo : entity work.servomoteur
        port map (
            clk      => CLOCK_50,
            reset_n  => '1',            -- Reset désactivé pour le test
            position => SW(7 downto 0), -- On garde 8 bits pour le moteur
            commande => pwm_signal
        );

    -- 4. Envoi du signal vers la sortie physique PIN_V10 (GPIO[0])
    GPIO(0) <= pwm_signal;

end architecture;
