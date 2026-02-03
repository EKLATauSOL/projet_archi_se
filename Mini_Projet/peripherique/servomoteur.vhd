library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servomoteur is
    port (
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        position  : in  std_logic_vector(7 downto 0);
        commande  : out std_logic
    );
end entity;

architecture bhv of servomoteur is
    -- 20 ms @ 50 MHz = 1 000 000 cycles
    constant CNT_PERIOD_MAX : integer := 1000000;

    -- Limites PWM pour atteindre 180° (0.6 ms à 2.4 ms)
    -- Base 0.6 ms = 30 000 cycles
    -- Max  2.4 ms = 120 000 cycles
    -- Pas = (120000 - 30000) / 255 = 353
    constant DUTY_MIN  : integer := 30000;
    constant DUTY_MAX  : integer := 120000;
    constant DUTY_STEP : integer := 353;

    signal counter    : integer range 0 to CNT_PERIOD_MAX := 0;
    signal duty_cycle : integer range 0 to DUTY_MAX := 75000; -- 1.5 ms par défaut (90°)

begin

    ------------------------------------------------------------------
    -- Calcul du duty cycle à partir de la position
    ------------------------------------------------------------------
    process(clk, reset_n)
        variable temp_duty : integer;
    begin
        if reset_n = '0' then
            duty_cycle <= 75000;
        elsif rising_edge(clk) then
            temp_duty := DUTY_MIN + (to_integer(unsigned(position)) * DUTY_STEP);
            
            -- Saturation de sécurité
            if temp_duty < DUTY_MIN then
                duty_cycle <= DUTY_MIN;
            elsif temp_duty > DUTY_MAX then
                duty_cycle <= DUTY_MAX;
            else
                duty_cycle <= temp_duty;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Génération du PWM
    ------------------------------------------------------------------
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            counter  <= 0;
            commande <= '0';
        elsif rising_edge(clk) then
            -- Compteur de période (20 ms)
            if counter < CNT_PERIOD_MAX then
                counter <= counter + 1;
            else
                counter <= 0;
            end if;

            -- Signal PWM
            if counter < duty_cycle then
                commande <= '1';
            else
                commande <= '0';
            end if;
        end if;
    end process;

end architecture;
