library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity telemetre_us_avalon is
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        
        -- Interface Avalon-MM Slave
        chipselect  : in  std_logic;
        read_n      : in  std_logic;
        readdata    : out std_logic_vector(31 downto 0);
        
        -- Interface Conduit (Vers l'extérieur)
        trig        : out std_logic;
        echo        : in  std_logic;
        dist_export : out std_logic_vector(9 downto 0) -- Pour afficher sur les LEDs
    );
end entity;

architecture rtl of telemetre_us_avalon is

    component telemetre_us is
        port (
            clk     : in  std_logic;
            rst_n   : in  std_logic;
            echo    : in  std_logic;
            trig    : out std_logic;
            dist_cm : out std_logic_vector(9 downto 0)
        );
    end component;

    signal dist_cm_sig : std_logic_vector(9 downto 0);

begin

    -- Instanciation du coeur du télémètre
    u0 : telemetre_us
        port map (
            clk     => clk,
            rst_n   => rst_n,
            echo    => echo,
            trig    => trig,
            dist_cm => dist_cm_sig
        );
        
    -- Connexion de la sortie Conduit (pour les LEDs)
    dist_export <= dist_cm_sig;

    -- Gestion de la lecture Avalon
    -- L'adresse n'est pas nécessaire car il n'y a qu'un seul registre à lire
    process(clk)
    begin
        if rising_edge(clk) then
            if chipselect = '1' and read_n = '0' then
                readdata <= (others => '0');          -- Mise à zéro des bits de poids fort
                readdata(9 downto 0) <= dist_cm_sig;  -- Assignation de la distance
            end if;
        end if;
    end process;

end architecture;
