----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:23:51 09/29/2014 
-- Design Name: 
-- Module Name:    position_counter - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity position_counter is
    Port ( clk : in  STD_LOGIC;
           dir : in  STD_LOGIC;
           en  : in  STD_LOGIC;
			  pre : in STD_LOGIC;
			  reset: in STD_LOGIC;
           srt_pos : in  STD_LOGIC_VECTOR (4 downto 0);
           current_pos : out  STD_LOGIC_VECTOR (4 downto 0));
end position_counter;

architecture Behavioral of position_counter is

	signal count : integer RANGE 0 TO 19;

begin

	process(clk, reset, srt_pos, en, pre)
	begin
		
		-- if reset, set the counter at the inital value
		if reset = '1' then
			count <= 0;
			
		-- Statments for clk edge
		elsif rising_edge(clk) then
			
			-- preset high, load the inital value
			if (en = '1' and pre = '1') then
				count <= conv_integer(srt_pos);
			
			-- counting up
			elsif (en = '1' and pre = '0' and dir = '1') then
				
				if count = 19 then
					count <= 0; 
				else
					count <= count + 1;
				end if;
			
			-- counting down		
			elsif (en = '1' and pre = '0' and dir = '0') then
						
				if count = 0 then
					count <= 19;
				else
					count <= count - 1;
				end if;
					
			end if; 			
			
		end if; 
					
	end process;
	
	current_pos <= conv_std_logic_vector(count,5);

end Behavioral;

