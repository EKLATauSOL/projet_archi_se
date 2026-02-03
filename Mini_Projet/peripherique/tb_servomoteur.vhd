library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_servomoteur is
end entity;

architecture test of tb_servomoteur is
    signal clk      : std_logic := '0';
    signal reset_n  : std_logic := '0';
    signal position : std_logic_vector(7 downto 0) := (others => '0');
    signal commande : std_logic;

    constant CLK_PERIOD : time := 20 ns; -- 50 MHz
begin
    -- Instanciation de l'UUT (Unit Under Test)
    uut: entity work.servomoteur
        port map (
            clk      => clk,
            reset_n  => reset_n,
            position => position,
            commande => commande
        );

    -- Génération de l'horloge
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimuli
    stim_proc: process
    begin
        -- Initialisation
        reset_n <= '0';
        position <= x"00";
        wait for 100 ns;
        reset_n <= '1';

        -- Test Position 0 (doit donner une impulsion de 1ms)
        position <= x"00";
        report "Test Position 0 (0 degres)";
        wait for 21 ms; -- Attendre une période PWM complète (20ms + marge)

        -- Test Position 127 (approx 90 degres, doit donner une impulsion de ~1.5ms)
        position <= x"7F";
        report "Test Position 127 (approx 90 degres)";
        wait for 20 ms;

        -- Test Position 255 (180 degres, doit donner une impulsion de 2ms)
        position <= x"FF";
        report "Test Position 255 (180 degres)";
        wait for 20 ms;

        report "Fin de la simulation";
        wait;
    end process;

end architecture;
