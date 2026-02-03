library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IP_Servo_Avalon is
    port (
        clk          : in  std_logic;                     -- Horloge système 50 MHz
        reset_n      : in  std_logic;                     -- Reset actif bas
        
        -- Interface Avalon Slave
        chipselect   : in  std_logic;                     -- Sélection du périphérique
        write_n      : in  std_logic;                     -- Autorisation d'écriture (actif bas)
        writedata    : in  std_logic_vector(31 downto 0); -- Données sur 32 bits
        
        -- Sortie physique
        commande     : out std_logic                      -- Signal PWM vers le servomoteur
    );
end entity;

architecture rtl of IP_Servo_Avalon is
    -- Registre interne pour stocker la position (8 bits suffisent pour 0-255)
    signal reg_position : std_logic_vector(7 downto 0) := x"7F"; -- Valeur par défaut : milieu (90°)
begin

    ------------------------------------------------------------------
    -- Processus d'écriture sur le bus Avalon
    ------------------------------------------------------------------
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_position <= x"7F"; -- Reset à la position centrale
        elsif rising_edge(clk) then
            -- Écriture si chipselect est actif et write_n est bas
            if chipselect = '1' and write_n = '0' then
                reg_position <= writedata(7 downto 0);
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Instanciation de la partie opérative (Contrôleur PWM)
    ------------------------------------------------------------------
    u_pwm_servo : entity work.servomoteur
        port map (
            clk      => clk,
            reset_n  => reset_n,
            position => reg_position,
            commande => commande
        );

end architecture;
