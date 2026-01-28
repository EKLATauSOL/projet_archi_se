library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_telemetre_us is
end entity;

architecture test of tb_telemetre_us is

    component telemetre_us
        port (
            clk       : in  std_logic;
            rst_n     : in  std_logic;
            echo      : in  std_logic;
            trig      : out std_logic;
            dist_cm   : out std_logic_vector(9 downto 0)
        );
    end component;

    signal clk       : std_logic := '0';
    signal rst_n     : std_logic := '0';
    signal echo      : std_logic := '0';
    signal trig      : std_logic;
    signal dist_cm   : std_logic_vector(9 downto 0);

    -- Clock period definitions
    constant clk_period : time := 20 ns; -- 50 MHz

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: telemetre_us
        port map (
            clk     => clk,
            rst_n   => rst_n,
            echo    => echo,
            trig    => trig,
            dist_cm => dist_cm
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns.
        rst_n <= '0';
        wait for 100 ns;
        rst_n <= '1';
        
        wait for 100 ns;

        -- Le module doit générer un Trigger automatiquement.
        -- On attend le front montant du trigger.
        wait until rising_edge(trig);
        report "Trigger detected!";
        
        -- Le capteur réel met un peu de temps avant de répondre (holdoff), par ex 200us
        wait for 200 us;
        
        -- Simulation d'un retour d'écho pour une distance de 10 cm.
        -- Temps = 10 cm * 58 us/cm = 580 us.
        report "Simulating Echo for 10 cm (580 us)";
        echo <= '1';
        wait for 580 us;
        echo <= '0';

        wait for 1 ms;

        -- Attendre le prochain cycle de trigger (cycle total de 60ms)
        wait until rising_edge(trig);
        report "Second Trigger detected!";
        
         -- Simulation d'un retour d'écho pour une distance de 50 cm.
        -- Temps = 50 cm * 58 us/cm = 2900 us = 2.9 ms
        wait for 200 us;
        report "Simulating Echo for 50 cm (2.9 ms)";
        echo <= '1';
        wait for 2900 us;
        echo <= '0';

        wait for 10 ms;

        assert false report "End of Simulation" severity failure;
    end process;

end architecture;
