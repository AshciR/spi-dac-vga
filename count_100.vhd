----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: Richard Walker
-- 
-- Create Date:    19:00:15 10/03/2014 
-- Design Name: 
-- Module Name:    count_100 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 0 to 99 Counter for the sine wave generator
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

entity count_100 is
    Port ( clock_in : in  STD_LOGIC;
           enable : in  STD_LOGIC;
			  reset  : in STD_LOGIC;
           counter_out : out  STD_LOGIC_VECTOR (6 downto 0));
end count_100;

architecture Behavioral of count_100 is

signal count : integer range 0 to 99;

begin

	-- count from 0 to 99 
	process(reset, clock_in, enable)
	begin
		if enable = '1' then
			if reset = '1' then
				count <= 0;
			elsif rising_edge(clock_in) then
				if count = 99 then
					count <= 0;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process; 
	
	counter_out <= conv_std_logic_vector(count,7);

end Behavioral;
