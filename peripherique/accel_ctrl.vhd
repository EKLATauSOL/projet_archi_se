library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accel_ctrl is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        -- Avalon-MM slave
        avs_address     : in  std_logic_vector(1 downto 0);
        avs_read        : in  std_logic;
        avs_write       : in  std_logic;
        avs_writedata   : in  std_logic_vector(31 downto 0);
        avs_readdata    : out std_logic_vector(31 downto 0);
        avs_waitrequest : out std_logic;

        -- Accelerometer Interface (ADXL345)
        GSENSOR_CS_N    : out std_logic;
        GSENSOR_SCLK    : out std_logic;
        GSENSOR_SDI     : inout std_logic; -- Bidirectional if 3-wire, but usually SDIO. For 4-wire: SDI(input to slave), SDO(output from slave). 
                                           -- DE10-Lite usually uses 3-wire or 4-wire. Let's assume 4-wire standard.
                                           -- Wait, DE10-Lite schematic typically shows:
                                           -- GSENSOR_CS_N, GSENSOR_SCLK, GSENSOR_SDI, GSENSOR_SDO.
                                           -- So I will use distinct input/output ports.
        GSENSOR_SDO     : in  std_logic -- Input from slave (MISO)
    );
end entity;

architecture rtl of accel_ctrl is

    -- SPI Configuration
    constant CLK_FREQ   : integer := 50_000_000; -- 50 MHz
    constant SPI_FREQ   : integer := 1_000_000;  -- 1 MHz SPI
    constant DIVIDER    : integer := CLK_FREQ / (2 * SPI_FREQ); -- Toggle every half period
    -- SPI State
    type state_type is (RESET_STATE, INIT_START, INIT_SEND, READ_START, READ_SEND, READ_RECV, IDLE);
    signal state        : state_type := RESET_STATE;
    signal clk_cnt      : integer range 0 to DIVIDER := 0;
    signal sclk_reg     : std_logic := '1';
    
    -- Data Transmission
    signal spi_bit_cnt  : integer range 0 to 63;
    signal tx_data      : std_logic_vector(15 downto 0); -- Command + Data/Addr
    signal rx_data      : std_logic_vector(15 downto 0);
    signal data_buffer  : std_logic_vector(47 downto 0); -- X, Y, Z (6 bytes)
    
    -- Registers
    signal x_reg        : std_logic_vector(15 downto 0);
    signal y_reg        : std_logic_vector(15 downto 0);
    signal z_reg        : std_logic_vector(15 downto 0);
    signal ready        : std_logic := '0';
    
    -- Init Sequence: Set POWER_CTL (0x2D) to 0x08 (Measure)
    -- Write: 0x2D (Addr) | 0x00 (Write bit 7=0, MB=0) -> 00101101
    -- Data: 0x08
    constant INIT_CMD   : std_logic_vector(15 downto 0) := x"2D08";
    
    -- Read Sequence: Read 6 bytes from DATAX0 (0x32)
    -- CMD: 0x32 | Read (1) | MB (1) -> 11110010 -> 0xF2
    constant READ_CMD   : std_logic_vector(7 downto 0) := x"F2";
    
    signal init_done    : std_logic := '0';
    signal update_cnt   : integer range 0 to 5000000 := 0; -- Update rate 10Hz
    
    -- SPI Signals
    signal cs_n_reg     : std_logic := '1';
    signal mosi_reg     : std_logic := '1'; -- We drive SDI
    
    -- 4-Wire SPI mapping:
    -- FPGA_SDO -> GSENSOR_SDI (MOSI)
    -- FPGA_SDI <- GSENSOR_SDO (MISO)

begin
    
    GSENSOR_CS_N <= cs_n_reg;
    GSENSOR_SCLK <= sclk_reg;
    GSENSOR_SDI  <= mosi_reg; -- This is MOSI

    -- Avalon Read Process
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                avs_readdata <= (others => '0');
            elsif avs_read = '1' then
                case avs_address is
                    when "00" => avs_readdata(15 downto 0) <= x_reg; avs_readdata(31 downto 16) <= (others => '0');
                    when "01" => avs_readdata(15 downto 0) <= y_reg; avs_readdata(31 downto 16) <= (others => '0');
                    when "10" => avs_readdata(15 downto 0) <= z_reg; avs_readdata(31 downto 16) <= (others => '0');
                    when "11" => avs_readdata <= (0 => ready, others => '0');
                    when others => avs_readdata <= (others => '0');
                end case;
            end if;
        end if;
    end process;
    avs_waitrequest <= '0';

    -- SPI Controller
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= RESET_STATE;
                cs_n_reg <= '1';
                sclk_reg <= '1';
                init_done <= '0';
                ready <= '0';
            else
                case state is
                    when RESET_STATE =>
                        update_cnt <= update_cnt + 1;
                        if update_cnt > 50000 then -- Wait 1ms
                             state <= INIT_START;
                             update_cnt <= 0;
                        end if;
                    
                    when INIT_START =>
                        cs_n_reg <= '0';
                        tx_data <= INIT_CMD;
                        spi_bit_cnt <= 15;
                        state <= INIT_SEND;
                        clk_cnt <= 0;
                        sclk_reg <= '1'; -- CPOL=1
                        
                    when INIT_SEND =>
                        if clk_cnt = DIVIDER then
                             clk_cnt <= 0;
                             sclk_reg <= not sclk_reg;
                             if sclk_reg = '1' then -- Falling Miso
                                 mosi_reg <= tx_data(spi_bit_cnt);
                             else -- Rising
                                 if spi_bit_cnt = 0 then
                                     state <= IDLE;
                                     cs_n_reg <= '1';
                                     init_done <= '1';
                                 else
                                     spi_bit_cnt <= spi_bit_cnt - 1;
                                 end if;
                             end if;
                        else
                             clk_cnt <= clk_cnt + 1;
                        end if;
                        
                    when IDLE =>
                        cs_n_reg <= '1';
                        mosi_reg <= '1';
                        if update_cnt < 500000 then -- 100Hz
                             update_cnt <= update_cnt + 1;
                        else
                             update_cnt <= 0;
                             state <= READ_START;
                        end if;
                        
                    when READ_START =>
                        cs_n_reg <= '0';
                        tx_data(15 downto 8) <= READ_CMD;
                        spi_bit_cnt <= 7;
                        state <= READ_SEND;
                        clk_cnt <= 0;
                        sclk_reg <= '1';
                        
                    when READ_SEND => -- Send Command
                         if clk_cnt = DIVIDER then
                             clk_cnt <= 0;
                             sclk_reg <= not sclk_reg;
                             if sclk_reg = '1' then -- Falling Edge setup data
                                 mosi_reg <= tx_data(spi_bit_cnt + 8); 
                             else -- Rising Edge
                                 if spi_bit_cnt = 0 then
                                     state <= READ_RECV;
                                     spi_bit_cnt <= 47; -- Read 6 bytes (48 bits)
                                 else
                                     spi_bit_cnt <= spi_bit_cnt - 1;
                                 end if;
                             end if;
                        else
                             clk_cnt <= clk_cnt + 1;
                        end if;
                        
                    when READ_RECV => -- Receive Data
                         mosi_reg <= '1'; -- Idle high
                         if clk_cnt = DIVIDER then
                             clk_cnt <= 0;
                             sclk_reg <= not sclk_reg;
                             if sclk_reg = '0' then -- Rising Edge Sample
                                 data_buffer(spi_bit_cnt) <= GSENSOR_SDO;
                                 if spi_bit_cnt = 0 then
                                     state <= IDLE;
                                     cs_n_reg <= '1';
                                     -- Update Registers (Little Endian: LSB is at higher index in bitstream? No, MSB of Byte 1 is at 47)
                                     -- Buffer: [Byte1 (X0)][Byte2 (X1)][Byte3 (Y0)][Byte4 (Y1)][Byte5 (Z0)][Byte6 (Z1)] (Indices 47 down to 0)
                                     -- X = X1 & X0 = Byte2 & Byte1 = buffer(39..32) & buffer(47..40)
                                     x_reg <= data_buffer(39 downto 32) & data_buffer(47 downto 40);
                                     y_reg <= data_buffer(23 downto 16) & data_buffer(31 downto 24);
                                     z_reg <= data_buffer(7 downto 0)   & data_buffer(15 downto 8);
                                     ready <= '1';
                                 else
                                     spi_bit_cnt <= spi_bit_cnt - 1;
                                 end if;
                             end if;
                        else
                             clk_cnt <= clk_cnt + 1;
                        end if;
                        
                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end architecture;
