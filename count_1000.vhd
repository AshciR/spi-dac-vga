----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: Richard Walker
-- 
-- Create Date:    19:00:15 10/03/2014 
-- Design Name: 
-- Module Name:    count_1000 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 0 to 999 Counter for the sine wave generator
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity count_1000 is
    Port ( clock_in : in  STD_LOGIC;
           enable : in  STD_LOGIC;
			  reset  : in STD_LOGIC;
           counter_out : out  STD_LOGIC);
end count_1000;

architecture Behavioral of count_1000 is

signal count : integer range 0 to 499;
signal clk_out : std_logic := '0'; -- signals that the clock reached max count

begin

	-- count from 0 to 499 
	process(reset, clock_in, enable)
	begin
		if enable = '1' then
			if reset = '1' then
				count <= 0;
			elsif rising_edge(clock_in) then
				
				-- Half the period
				if count = 499 then
					count <= 0;
					
					-- reached max count
					clk_out <= not clk_out;
				else
					count <= count + 1;
					
					-- did not reach max count 
					clk_out <= clk_out;
				end if;
			end if;
		end if;
	end process; 
	
	counter_out <= clk_out;

end Behavioral;
