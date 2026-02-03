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

        -- =========================================================
        -- CAS 1 : PAS D'ECHO (Timeout)
        -- =========================================================
        wait until rising_edge(trig);
        report "CAS 1: Trigger detected (No Echo Test)";
        -- On ne lève jamais 'echo', on laisse le timeout agir
        echo <= '0';
        
        -- =========================================================
        -- CAS 2 : ECHO DE 20 cm
        -- =========================================================
        -- Attendre le prochain cycle (auto 60ms)
        wait until rising_edge(trig);
        report "CAS 2: Trigger detected (20 cm Test)";
        wait for 200 us; -- Temps de réponse capteur
        
        -- Durée = 20 * 58 us = 1160 us
        report "Simulating Echo for 20 cm (1160 us)";
        echo <= '1';
        wait for 1160 us;
        echo <= '0';

        -- =========================================================
        -- CAS 3 : ECHO MAX (400 cm)
        -- =========================================================
        wait until rising_edge(trig);
        report "CAS 3: Trigger detected (400 cm Test)";
        wait for 200 us;
        
        -- Durée = 400 * 58 us = 23200 us = 23.2 ms
        report "Simulating Echo for 400 cm (23.2 ms)";
        echo <= '1';
        wait for 23200 us;
        echo <= '0';

        wait for 100 ms; -- Wait enough time to see the end
        assert false report "End of Simulation" severity failure;
    end process;

end architecture;
