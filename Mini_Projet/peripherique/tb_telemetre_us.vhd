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
        -- MESURE 1 : 0 cm
        -- =========================================================
        wait until rising_edge(trig);
        report "Trigger 1 détecté !";
        
        wait for 200 us; 
        
        -- Simulation Echo pour 0 cm (durée < 58us)
        report "Simulation de l'Echo pour 0 cm (10 us)";
        echo <= '1';
        wait for 10 us; 
        echo <= '0';

        -- =========================================================
        -- MESURE 2 : 20 cm
        -- =========================================================
        wait until rising_edge(trig);
        report "Trigger 2 détecté !";
        
        wait for 200 us;
        
        -- Simulation Echo pour 20 cm
        report "Simulation de l'Echo pour 20 cm (1160 us)";
        echo <= '1';
        wait for 1160 us; 
        echo <= '0';

        -- =========================================================
        -- MESURE 3 : 400 cm
        -- =========================================================
        wait until rising_edge(trig);
        report "Trigger 3 détecté !";
        
        wait for 200 us;

        -- Simulation Echo pour 400 cm
        report "Simulation de l'Echo pour 400 cm (23.2 ms)";
        echo <= '1';
        wait for 23200 us; 
        echo <= '0';

        -- EXTENSION DE LA DUREE
        report "Attente résultat final...";
        wait for 100 ms; -- On attend largement assez pour voir le reset et la fin du cycle

        assert false report "Fin de la Simulation" severity failure;
    end process;

end architecture;