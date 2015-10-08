----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:11 09/26/2014 
-- Design Name: 
-- Module Name:    box_pos_decoder - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity box_pos_decoder is
    Port ( box_pos : in  STD_LOGIC_VECTOR (9 downto 0);
           seven_seg_data_in : out  STD_LOGIC_VECTOR (15 downto 0));
end box_pos_decoder;

architecture Behavioral of box_pos_decoder is

	-- Current positions for block at (x,y)
	signal x_pos: std_logic_vector(4 downto 0); 
	signal y_pos: std_logic_vector(4 downto 0); 
	
	-- Digits for each number
	signal digit_3: std_logic_vector(3 downto 0);
	signal digit_2: std_logic_vector(3 downto 0);
	signal digit_1: std_logic_vector(3 downto 0);
	signal digit_0: std_logic_vector(3 downto 0);
	
	
begin
	
	-- Splice the x and y positions
	-- The top 5 bits are the x-coord, 
	-- the bottom 5 are the the y-coord.
	x_pos <= box_pos(9 downto 5);
	y_pos <= box_pos(4 downto 0);	
	
	-- Combines the digit data into a 16-bit bus
	seven_seg_data_in <= digit_3 & digit_2 & digit_1 & digit_0;
	
	-- Decode the x position
	process(x_pos)
	begin
		-- if x_position less than 10, then set digit_1 to display 0
		if (x_pos < "01010") then
			digit_3 <= "0000";
		-- else it's more than 9, so set digit_1 to display 1
		else
			digit_3 <= "0001";
		end if;
		
		-- decode to determine what digit_0 should be
		case x_pos is
			-- 0 to 9
			when "00000" => digit_2 <= "0000";
			when "00001" => digit_2 <= "0001";
			when "00010" => digit_2 <= "0010";
			when "00011" => digit_2 <= "0011";
			when "00100" => digit_2 <= "0100";
			when "00101" => digit_2 <= "0101";
			when "00110" => digit_2 <= "0110";
			when "00111" => digit_2 <= "0111";
			when "01000" => digit_2 <= "1000";
			when "01001" => digit_2 <= "1001";
			
			-- 10 to 19
			when "01010" => digit_2 <= "0000";
			when "01011" => digit_2 <= "0001";
			when "01100" => digit_2 <= "0010";
			when "01101" => digit_2 <= "0011";
			when "01110" => digit_2 <= "0100";
			when "01111" => digit_2 <= "0101";
			when "10000" => digit_2 <= "0110";
			when "10001" => digit_2 <= "0111";
			when "10010" => digit_2 <= "1000";
			when others  => digit_2 <= "1001";
		end case;
	
	end process;
	
	-- Decode the y position
	process(y_pos)
	begin
		-- if x_position less than 10, then set digit_1 to display 0
		if (y_pos < "01010") then
			digit_1 <= "0000";
		-- else it's more than 9, so set digit_1 to display 1
		else
			digit_1 <= "0001";
		end if;
		
		-- decode to determine what digit_2 should be
		case y_pos is
			-- 0 to 9
			when "00000" => digit_0 <= "0000";
			when "00001" => digit_0 <= "0001";
			when "00010" => digit_0 <= "0010";
			when "00011" => digit_0 <= "0011";
			when "00100" => digit_0 <= "0100";
			when "00101" => digit_0 <= "0101";
			when "00110" => digit_0 <= "0110";
			when "00111" => digit_0 <= "0111";
			when "01000" => digit_0 <= "1000";
			when "01001" => digit_0 <= "1001";
			
			-- 10 to 19
			when "01010" => digit_0 <= "0000";
			when "01011" => digit_0 <= "0001";
			when "01100" => digit_0 <= "0010";
			when "01101" => digit_0 <= "0011";
			when "01110" => digit_0 <= "0100";
			when "01111" => digit_0 <= "0101";
			when "10000" => digit_0 <= "0110";
			when "10001" => digit_0 <= "0111";
			when "10010" => digit_0 <= "1000";
			when others  => digit_0 <= "1001";

			
		end case;
	
	end process;

end Behavioral;

