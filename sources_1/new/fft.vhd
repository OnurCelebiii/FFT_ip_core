library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fft is
Port (
    clock : in std_logic;
   -- reset : in std_logic;
    --fft_start_i : in std_logic;
    fft_o : out std_logic_vector(31 downto 0)
);
end fft;

architecture Behavioral of fft is

COMPONENT dds_compiler_0
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

COMPONENT my_fft
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tuser : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tready : IN STD_LOGIC;
    m_axis_data_tlast : OUT STD_LOGIC;
    event_frame_started : OUT STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_status_channel_halt : OUT STD_LOGIC;
    event_data_in_channel_halt : OUT STD_LOGIC;
    event_data_out_channel_halt : OUT STD_LOGIC
  );
END COMPONENT;
----------------fft signal-------------------
signal fft_data_in : std_logic_vector(31 downto 0); 
signal fft_data_valid_in : std_logic;
signal fft_data_last_in : std_logic;
signal fft_data_out : std_logic_vector(31 downto 0);
signal fft_user_out : std_logic_vector(15 downto 0);
signal fft_data_valid_out : std_logic;
signal fft_data_last_out : std_logic;
--------------dds signal-----------------------
signal dds_phase_in :std_logic_vector(15 downto 0) := x"00FF";
signal dds_phase_valid_in : std_logic := '1';
signal dds_valid_out : std_logic;
signal dds_out : std_logic_vector(15 downto 0);
------------------------------------------
begin

fft_o <= fft_data_out;

-------------------fft--------------------
fft : my_fft
  PORT MAP (
    aclk => clock,
    s_axis_config_tdata     =>(others => '0'),
    s_axis_config_tvalid    => '0',
    s_axis_config_tready    => open,
    s_axis_data_tdata       => fft_data_in,
    s_axis_data_tvalid  => fft_data_valid_in,
    s_axis_data_tready => open,
    s_axis_data_tlast => fft_data_last_in,
    m_axis_data_tdata => fft_data_out,
    m_axis_data_tuser => fft_user_out,
    m_axis_data_tvalid => fft_data_valid_out,
    m_axis_data_tready => '1',
    m_axis_data_tlast => fft_data_last_out,
    event_frame_started => open,
    event_tlast_unexpected => open,
    event_tlast_missing => open,
    event_status_channel_halt => open,
    event_data_in_channel_halt => open,
    event_data_out_channel_halt => open
  );
--------------------------------------------
---------------------dds--------------------
  dds : dds_compiler_0
  PORT MAP (
    aclk => clock,
    s_axis_config_tvalid    =>      dds_phase_valid_in      ,
    s_axis_config_tdata     =>      dds_phase_in            ,
    m_axis_data_tvalid      =>      dds_valid_out           ,
    m_axis_data_tdata       =>      dds_out
  );

fft11 : process (clock) 

--variable fft_counter : integer range 0 to 1024 ;
begin
    if (rising_edge (clock)) then
        --if fft_counter < 1024 then
            fft_data_valid_in   <=      '1'                  ;
            fft_data_in         <=      x"0000" & dds_out    ;
          --  fft_counter         :=      fft_counter + 1      ;
        end if;
       -- else 
           -- fft_data_last_in <= '0';
    --end if;


end process;
end Behavioral;