----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: Richard Walker
-- 
-- Create Date:    20:43:22 09/28/2014 
-- Design Name: 
-- Module Name:    shift_16 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 16-bit Shfit Register Module
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_16 is
    Port ( load : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  enable: in STD_LOGIC;
           left_right : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (15 downto 0);
           q : out  STD_LOGIC_VECTOR (15 downto 0));
end shift_16;

architecture Behavioral of shift_16 is
	
	-- Temp variable to hold the output of the register
	signal temp : std_logic_vector(15 downto 0);

begin
	
	process(clk, enable)
	begin
		
		if rising_edge(clk) and (enable ='1') then
				
				-- Load is active high, load data into the register
				if load = '1' then
					temp <= data;
				
				-- shift left
				elsif left_right = '0' then
					temp <= temp(14 downto 0) & '0';
				
				-- shift right
				else 
					temp <= '0' & temp(15 downto 1);
				end if;
		
		end if;
	
	end process;
	
	q <= temp;

end Behavioral;

