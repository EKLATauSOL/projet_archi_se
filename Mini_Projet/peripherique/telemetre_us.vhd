library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity telemetre_us is
    port (
        clk       : in  std_logic;                     -- Horloge 50 MHz
        rst_n     : in  std_logic;                     -- Reset actif bas
        echo      : in  std_logic;                     -- Entrée Echo du capteur
        trig      : out std_logic;                     -- Sortie Trigger vers le capteur
        dist_cm   : out std_logic_vector(9 downto 0)   -- Distance mesurée en cm
    );
end entity;

architecture bhv of telemetre_us is
    -- Constantes pour 50 MHz (période 20ns)
    -- 60 ms = 60,000,000 ns / 20 ns = 3,000,000 cycles
    constant CNT_60MS_MAX  : integer := 3000000;
    -- 10 µs = 10,000 ns / 20 ns = 500 cycles
    constant CNT_10US_MAX  : integer := 500;
    -- 58 µs = 58,000 ns / 20 ns = 2900 cycles (Temps pour parcourir 1 cm aller-retour)
    constant CNT_58US_MAX  : integer := 2900;

    signal cnt_global      : integer range 0 to CNT_60MS_MAX := 0;
    signal cnt_echo        : integer range 0 to CNT_58US_MAX := 0;
    signal distance_buffer : unsigned(9 downto 0) := (others => '0');
    signal echo_sync       : std_logic;
    signal echo_prev       : std_logic;
    signal dist_cm_reg     : std_logic_vector(9 downto 0) := (others => '0');

begin

    -- Processus principal
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            cnt_global      <= 0;
            cnt_echo        <= 0;
            trig            <= '0';
            distance_buffer <= (others => '0');
            echo_sync       <= '0';
            echo_prev       <= '0';
        elsif rising_edge(clk) then
            -- 1. Synchronisation du signal echo (éviter métastabilité)
            echo_sync <= echo;
            echo_prev <= echo_sync;

            -- 2. Gestion du Trigger et du cycle de 60ms
            if cnt_global < CNT_60MS_MAX then
                cnt_global <= cnt_global + 1;
            else
                cnt_global <= 0;
            end if;

            -- Génération du pulse Trigger (10 µs au début du cycle)
            if cnt_global < CNT_10US_MAX then
                trig <= '1';
            else
                trig <= '0';
            end if;

            -- 3. Mesure de la largeur d'impulsion de l'Echo
            if echo_sync = '1' then
                if cnt_echo < CNT_58US_MAX then
                    cnt_echo <= cnt_echo + 1;
                else
                    -- Chaque fois qu'on atteint 58µs, on incrémente la distance de 1cm
                    cnt_echo <= 0;
                    if distance_buffer < 500 then -- Limite max raisonnable (500 cm)
                        distance_buffer <= distance_buffer + 1;
                    end if;
                end if;
            else
                -- Si echo est bas, on remet le compteur partielle à 0
                cnt_echo <= 0;
                
                -- Detect Falling Edge of Echo to update output
                if echo_prev = '1' and echo_sync = '0' then
                    dist_cm_reg <= std_logic_vector(distance_buffer);
                end if;
                
                -- On reset le buffer au début du prochain cycle de trigger pour une nouvelle mesure
                if cnt_global = 0 then
                    distance_buffer <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    dist_cm <= dist_cm_reg;

end architecture;
