library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_IP_Servo_Avalon is
end entity;

architecture test of tb_IP_Servo_Avalon is
    -- Signaux
    signal clk          : std_logic := '0';
    signal reset_n      : std_logic := '0';
    signal chipselect   : std_logic := '0';
    signal write_n      : std_logic := '1';
    signal writedata    : std_logic_vector(31 downto 0) := (others => '0');
    signal commande     : std_logic;

    constant CLK_PERIOD : time := 20 ns; -- 50 MHz
begin

    -- Instanciation de l'IP Avalon
    uut: entity work.IP_Servo_Avalon
        port map (
            clk        => clk,
            reset_n    => reset_n,
            chipselect => chipselect,
            write_n    => write_n,
            writedata  => writedata,
            commande   => commande
        );

    -- Horloge 50 MHz
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Stimuli Avalon
    stim_proc: process
    begin
        -- 1. Reset
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;

        -- 2. Écriture Position 0°
        report "Ecriture Avalon : Position 0";
        chipselect <= '1';
        write_n    <= '0';
        writedata  <= "00000000000000000000000000000000";
        wait for CLK_PERIOD;
        chipselect <= '0';
        write_n    <= '1';
        
        wait for 21 ms;

        -- 3. Écriture Position 90° (valeur 127)
        report "Ecriture Avalon : Position 90";
        chipselect <= '1';
        write_n    <= '0';
        writedata  <= "00000000000000000000000001111111";
        wait for CLK_PERIOD;
        chipselect <= '0';
        write_n    <= '1';

        wait for 21 ms;

        -- 4. Écriture Position 180° (valeur 255)
        report "Ecriture Avalon : Position 180";
        chipselect <= '1';
        write_n    <= '0';
        writedata  <= "00000000000000000000000011111111";
        wait for CLK_PERIOD;
        chipselect <= '0';
        write_n    <= '1';

        wait for 21 ms;

        report "Fin de simulation Avalon";
        wait;
    end process;

end architecture;
