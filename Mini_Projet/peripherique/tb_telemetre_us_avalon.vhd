library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_telemetre_us_avalon is
end entity;

architecture test of tb_telemetre_us_avalon is

    component telemetre_us_avalon
        port (
            clk         : in  std_logic;
            rst_n       : in  std_logic;
            chipselect  : in  std_logic;
            read_n      : in  std_logic;
            readdata    : out std_logic_vector(31 downto 0);
            trig        : out std_logic;
            echo        : in  std_logic;
            dist_export : out std_logic_vector(9 downto 0)
        );
    end component;

    signal clk         : std_logic := '0';
    signal rst_n       : std_logic := '0';
    signal chipselect  : std_logic := '0';
    signal read_n      : std_logic := '1';
    signal readdata    : std_logic_vector(31 downto 0);
    signal trig        : std_logic;
    signal echo        : std_logic := '0';
    signal dist_export : std_logic_vector(9 downto 0);

    constant clk_period : time := 20 ns;

    -- Signal purement décoratif pour simuler les ondes sonores (40 kHz)


begin

    uut : telemetre_us_avalon
        port map (
            clk         => clk,
            rst_n       => rst_n,
            chipselect  => chipselect,
            read_n      => read_n,
            readdata    => readdata,
            trig        => trig,
            echo        => echo,
            dist_export => dist_export
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Processus pour générer les "bips" ultrasoniques (visuel seulement)


    -- Stimulus process
    stim_proc : process
    begin
        -- Reset
        rst_n <= '0';
        wait for 100 ns;
        rst_n <= '1';
        
        wait for 100 ns;
        
        -- =========================================================
        -- CAS 1 : PAS D'ECHO (Timeout) -> Devrait lire 0 ou max
        -- =========================================================
        wait until rising_edge(trig);
        report "CAS 1: Trigger detected (No Echo Test)";
        echo <= '0';
        
        -- Attendre que le cycle se termine (60ms max) ou un temps suffisant avant lecture
        -- On attend le prochain trigger pour être sûr que la mesure est finie et stockée
        wait until rising_edge(trig);
        
        -- Lecture Avalon
        report "Reading from Avalon Bus (Case 1)...";
        wait until rising_edge(clk);
        chipselect <= '1';
        read_n     <= '0';
        wait until rising_edge(clk);
        report "Read Value: " & integer'image(to_integer(unsigned(readdata)));
        read_n     <= '1';
        chipselect <= '0';


        -- =========================================================
        -- CAS 2 : ECHO DE 20 cm
        -- =========================================================
        -- On vient d'avoir un rising_edge(trig) juste avant la lecture précédente
        report "CAS 2: Trigger detected (20 cm Test)";
        wait for 200 us; -- Temps de réponse capteur
        
        -- Durée = 20 * 58 us = 1160 us
        report "Simulating Echo for 20 cm (1160 us)";
        echo <= '1';
        wait for 1160 us;
        echo <= '0';
        
        -- Attendre un peu mais PAS jusqu'au prochain trigger, car le buffer se reset au début du cycle suivant !
        -- On est à env. 200us + 1160us = 1.36 ms dans le cycle de 60ms.
        -- On attend 10 ms pour être large et lire le résultat stable.
        wait for 10 ms;
        
        -- Lecture Avalon
        report "Reading from Avalon Bus (Case 2)...";
        wait until rising_edge(clk);
        chipselect <= '1';
        read_n     <= '0';
        wait until rising_edge(clk);
        report "Read Value: " & integer'image(to_integer(unsigned(readdata)));
        read_n     <= '1';
        chipselect <= '0';
        
        -- On attend la fin du cycle manuellement pour passer au test suivant proprement
        wait until rising_edge(trig);


        -- =========================================================
        -- CAS 3 : ECHO MAX (400 cm)
        -- =========================================================
        -- Trigger déjà détecté juste avant
        report "CAS 3: Trigger detected (400 cm Test)";
        wait for 200 us;
        
        -- Durée = 400 * 58 us = 23200 us = 23.2 ms
        report "Simulating Echo for 400 cm (23.2 ms)";
        echo <= '1';
        wait for 23200 us;
        echo <= '0';
        
        -- Attendre résultat
        wait for 30 ms; -- On attend un peu avant de lire
        
        -- Lecture Avalon
        report "Reading from Avalon Bus (Case 3)...";
        wait until rising_edge(clk);
        chipselect <= '1';
        read_n     <= '0';
        wait until rising_edge(clk);
        report "Read Value: " & integer'image(to_integer(unsigned(readdata)));
        read_n     <= '1';
        chipselect <= '0';
        
        wait for 100 ms;
        assert false report "End of Simulation" severity failure;
    end process;

end architecture;