----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: Richard Walker
-- 
-- Create Date:    17:26:30 10/04/2014 
-- Design Name: 
-- Module Name:    clk_10Hz - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Outputs a 10Hz clk from a 10MHz
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

entity clk_10Hz is
    Port ( clk_in : in  STD_LOGIC;
			  reset  : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end clk_10Hz;

architecture Behavioral of clk_10Hz is

-- Components --
	
	-- 1000 counter
	COMPONENT count_1000
	PORT(
		clock_in : IN std_logic;
		enable : IN std_logic;
		reset : IN std_logic;          
		counter_out : OUT std_logic
		);
	END COMPONENT;
	
----------------
	
	-- enable signal for the counters
	signal enable : std_logic;
	
	-- output from the 1st 1000 counter
	signal out_1000 : std_logic;
	
begin

	U1 : count_1000 PORT MAP(
		clock_in => clk_in, -- input clock (10Mhz)
		enable => enable,
		reset => reset,
		counter_out => out_1000 -- this will be the input to the 10000 counter
	);
	
	U2 : count_1000 PORT MAP(
		clock_in => out_1000, -- input clock (10kHz)
		enable => enable,
		reset => reset,
		counter_out => clk_out -- this will be the input to the 10000 counter
	);
	
	-- premanently enable the counters
	enable <= '1';
	
end Behavioral;


