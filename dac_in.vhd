----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: Richard Walker
-- 
-- Create Date:    21:31:01 09/28/2014 
-- Design Name: 
-- Module Name:    dac_in - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Module to interface with the DAC 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dac_in is
    Port ( clk_in : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  data_in : in  STD_LOGIC_VECTOR (15 downto 0);
			  load    : in STD_LOGIC;
           
           sync_data    : out  STD_LOGIC;
           data_out_bit : out  STD_LOGIC);
end dac_in;

architecture Behavioral of dac_in is

------- COMPONENTS -------------------------------

-- 16-bit shift register
component shift_16 is
    Port ( load : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  enable: in STD_LOGIC;
           left_right : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (15 downto 0);
           q : out  STD_LOGIC_VECTOR (15 downto 0));
end component shift_16;

-- 0 to 15 counter
component count_16 is
    Port ( clock_in : in  STD_LOGIC;
           enable : in  STD_LOGIC;
			  reset  : in STD_LOGIC;
           counter_out : out  STD_LOGIC_VECTOR (3 downto 0));
end component count_16;


-------- SIGNALS ---------------------------------
signal clk_sig    : std_logic; -- 10 MHz clock signal

signal data_out   : std_logic_vector(15 downto 0); -- data from the shift register
signal data_in_sig: std_logic_vector(15 downto 0); -- data into the shift register

signal cnt_en	   : std_logic; -- count enable
signal cnt_out	   : std_logic_vector(3 downto 0); -- counter value
signal cnt_reset  : std_logic; -- reset counter
signal shift_en   : std_logic; -- shift enable
signal load_en    : std_logic; -- shfit load enable

-------- CONSTANTS -------------------------------
constant shift_sig : std_logic := '0'; -- Enables shift left

------ SETUP STATE MACHINE PARAMETERS ----
type state_type is (idle, load_state, srt_shift);
signal current_state, next_state : state_type;

begin
	
	-- Assign the input clock to the clk signal line
	clk_sig <= clk_in;
	
	-- The data to be loaded into the shift reg
	data_in_sig <= data_in;
	
	---------------------------------------------------------
	
	-- 16-bit shift register
	U1 : shift_16  PORT MAP(
		 load => load_en,
		 clk => clk_sig,
		 enable => shift_en,
		 left_right => shift_sig,
		 data => data_in_sig,
		 q => data_out
	);
	
		-- 0-16 counter
	U2 : count_16  PORT MAP(
		 clock_in => clk_sig,
		 enable => cnt_en,
		 reset => cnt_reset,
		 counter_out => cnt_out
	);

	
	----- DAC STATE MACHINE -----
	
	-- Process block to keep track of the state memory
	state_memory: process(clk_sig, reset)
	begin
		if reset = '1' then
			current_state <= idle;
		elsif rising_edge(clk_sig) then
			current_state <= next_state;
		end if;
	end process state_memory;
	
	-- Process block to determine the next state 
	next_state_logic: process (current_state, load, cnt_out)
	begin
		
		case current_state is
			
			-- initialize the system, then wait on load to be pressed
			when idle =>
				
				-- disable the shift resgister 
				shift_en <= '0';
				
				-- disable shift register load
				load_en <= '0';
				
				-- disable sync, NB sync is ACTIVE LOW!
				sync_data <= '1';
				
				-- Enable and reset the counter
				cnt_reset <= '1';
				cnt_en <= '1';
				
				-- If the load is ready then go to load state
				-- Note that the value isn't actually set into the
				-- Shift register yet, b/c the register is disabled.
				if (load = '1') then
					next_state <= load_state;
				-- else loop in this state
				else
					next_state <= idle;
				end if;
			
			-- load state loads the value to the shift register
			when load_state =>
				
				-- enable the shift resgister 
				shift_en <= '1';
				
				-- and load the value into it
				load_en <= '1';
				
				-- Disable and reset the counter
				cnt_reset <= '0';
				cnt_en <= '0';
				
				-- Go to the shifting state
				next_state <= srt_shift;
				
			-- shifting state sets the sync low, then starts
			-- the shift register
			when srt_shift =>
				
				-- Set sync low
				sync_data <= '0';
				
				-- start the counter
				cnt_en <= '1';
				
				-- Disable the load value
				load_en <= '0';
				
				-- if the counter has not reached 15
				--	then keep shifting bits
				if (cnt_out /= "1111") then
					-- start shifting bits
					shift_en <= '1';
					
					-- Stay in this state
					next_state <= srt_shift;
					
				-- the counter reached 16, stop shifting.
				else
					-- stop shifting bits
					shift_en <= '0';
			
					-- stop the counter
					cnt_en <= '0';
				
					-- Your done shifting
					-- Go back to the idle state
					next_state <= idle;
				
				end if;
							
		end case; -- end current_state case
	
	end process next_state_logic;
			
	-- spit out the MSB of the shift register
	-- out to the DAC data
	data_out_bit <= data_out(15);
			
	
end Behavioral;

