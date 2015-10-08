----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:24:45 09/11/2014 
-- Design Name: 
-- Module Name:    count_to_4 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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

entity count_to_4 is
    Port ( clock_in : in  STD_LOGIC;
			  reset  : in STD_LOGIC;
           counter_out : out  STD_LOGIC_VECTOR (1 downto 0));
end count_to_4;

architecture Behavioral of count_to_4 is

signal count : integer range 0 to 3;

begin

	-- count from 0 to 3 with a frequency of 100MHz
	process(reset, clock_in)
		
		-- dummy variable that will increment count by 1, when it reaches 5000
		variable temp : integer := 0; 
	
	begin
		if reset = '1' then
			count <= 0;
		elsif rising_edge(clock_in) then
			temp := temp + 1;
			if temp = 5000 then
				temp := 0;
				if count = 3 then
					count <= 0;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process; 
	
	counter_out <= conv_std_logic_vector(count,2);

end Behavioral;

