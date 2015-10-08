----------------------------------------------------------------------------------
-- Company: WPI	
-- Engineer: Richard Walker
-- 
-- Create Date:    19:06:05 10/03/2014 
-- Design Name: 
-- Module Name:    sine_wave - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Generates a 6.25 kHz sine wave for the DAC
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

entity sine_wave is
    Port ( clk  : in  STD_LOGIC;
			  reset: in  STD_LOGIC;
			  DAC  : out STD_LOGIC_VECTOR(7 downto 0);
           load : out  STD_LOGIC);
end sine_wave;

architecture Behavioral of sine_wave is

------- COMPONENTS -------------------------------
	
	-- The mux that holds the sine wave values
	COMPONENT mux_16_to_1
	PORT(
		sel : IN std_logic_vector(3 downto 0);
		enable : IN std_logic;          
		q : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	-- The 0-99 counter for the DAC load
	COMPONENT count_100
	PORT(
		clock_in : IN std_logic;
		enable : IN std_logic;
		reset : IN std_logic;          
		counter_out : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;

	-- 0 to 15 counter for the MUX select
	COMPONENT count_16
	PORT(
		clock_in : IN std_logic;
		enable : IN std_logic;
		reset : IN std_logic;          
		counter_out : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

-- Constant to permanently enable the mux
constant mux_en    : std_logic := '1'; 

------- SIGNALS ----------------------

-- Mux signals --
signal sel_sig  : std_logic_vector(3 downto 0); -- select signal for the mux
signal DAC_data : std_logic_vector(7 downto 0); -- data sent to the DAC

-- DAC Counter signals --
signal dac_cnt_en   : std_logic; -- DAC Counter enable
signal dac_cnt_out  : std_logic_vector(6 downto 0); -- output from the counter

-- MUX Counter signals
signal mux_cnt_en    : std_logic; -- MUX Counter enable
signal mux_cnt_out   : std_logic_vector(3 downto 0); -- output from the counter

-- Clock signal --
signal clk_10MHz: std_logic; -- 10 MHz clock from the DCM

begin

	----- PORT MAPPINGS -------
	
	-- The mux
	U1: mux_16_to_1 PORT MAP(
		sel => sel_sig,
		enable => mux_en, -- always on
		q => DAC_data
	);
	
	-- The counter for DAC load
	U2: count_100 PORT MAP(
		clock_in => clk_10MHz,
		enable => dac_cnt_en,
		reset => reset, -- global reset
		counter_out => dac_cnt_out
	);
	
	-- Counter for MUX select
	U3: count_16 PORT MAP(
		clock_in => clk_10MHz,
		enable => mux_cnt_en,
		reset => reset,
		counter_out => mux_cnt_out 
	);
	----------------------------
	
	-- The output data from the mux
	-- gets set at the DAC data for the sine wave
	DAC <= DAC_data;
	
	-- The 10MHz clock
	clk_10MHz <= clk;
	
	-- The output from the 0-7 counter 
	-- drives the mux select signal
	sel_sig <= mux_cnt_out;
	
	-- Process to update the DAC data every 10us 
	-- (100 clk cycles) of a 10 MHZ clock.
	update_DAC: process(clk_10MHz, reset)
	begin
		
		if reset = '1' then
			
			-- disable the DAC counter
			dac_cnt_en <= '0';
			
			-- set load as low to signal the DAC not to load values
			load <= '0';

		elsif rising_edge(clk_10MHz) then
			
			-- enable the DAC counter, which counts to 99
			dac_cnt_en <= '1';
			
			-- if the count reaches 99 then activate the mux counter
			-- and load the signal
			if (dac_cnt_out = "1100011") then
			
				-- enable the mux counter
				mux_cnt_en <= '1';
				
				-- Load a value to the DAC
				load <= '1';
			
			-- else the DAC counter did not reach 99
			else
				
				-- disable the mux counter
				mux_cnt_en <= '0';
				
				-- don't load a value to the DAC
				load <= '0';
				
			end if;
		
		end if; -- End clock edge check
	
	end process update_DAC; -- end Update DAC Process
	
	
end Behavioral;


