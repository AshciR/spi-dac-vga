----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: Richard Walker
-- 
-- Create Date:    09/28/2014 
-- Design Name: 
-- Module Name:    count_16 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 0-15 Counter meant to be used with the DAC
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

entity count_16 is
    Port ( clock_in : in  STD_LOGIC;
           enable : in  STD_LOGIC;
			  reset  : in STD_LOGIC;
           counter_out : out  STD_LOGIC_VECTOR (3 downto 0));
end count_16;

architecture Behavioral of count_16 is

signal count : integer range 0 to 15;

begin

	-- count from 0 to 15 
	process(reset, clock_in, enable)
	begin
		if enable = '1' then
			if reset = '1' then
				count <= 0;
			elsif rising_edge(clock_in) then
				if count = 15 then
					count <= 0;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process; 
	
	counter_out <= conv_std_logic_vector(count,4);

end Behavioral;
