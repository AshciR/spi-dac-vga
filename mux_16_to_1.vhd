----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: Richard Walker
-- 
-- Create Date:    14:36:58 10/04/2014 
-- Design Name: 
-- Module Name:    mux_16_to_1 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Mux that holds the values needed to create a 6.25kHz sine wave
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

entity mux_16_to_1 is
    Port ( 		sel : in  STD_LOGIC_VECTOR (3 downto 0);
				enable : in  STD_LOGIC;
					  q : out STD_LOGIC_VECTOR (7 downto 0));
end mux_16_to_1;

architecture Behavioral of mux_16_to_1 is
	
	-- Constants that hold the DAC codes
	constant D_OFF : std_logic_vector(7 downto 0) := "00000000"; -- 0
	constant D0    : std_logic_vector(7 downto 0) := "01111111"; -- 127
	constant D1 	: std_logic_vector(7 downto 0) := "10101111"; -- 176
	constant D2		: std_logic_vector(7 downto 0) := "11011000"; -- 217
	constant D3 	: std_logic_vector(7 downto 0) := "11110100"; -- 244
	constant D4 	: std_logic_vector(7 downto 0) := "11111110"; -- 254
	constant D5 	: std_logic_vector(7 downto 0) := "11110100"; -- 244
	constant D6 	: std_logic_vector(7 downto 0) := "11011000"; -- 217
	constant D7 	: std_logic_vector(7 downto 0) := "10101111"; -- 176
	constant D8    : std_logic_vector(7 downto 0) := "01111111"; -- 127
	constant D9 	: std_logic_vector(7 downto 0) := "01001110"; -- 78
	constant D10 	: std_logic_vector(7 downto 0) := "00100101"; -- 37
	constant D11 	: std_logic_vector(7 downto 0) := "00001001"; -- 10
	constant D12	: std_logic_vector(7 downto 0) := "00000000"; -- 0
	constant D13   : std_logic_vector(7 downto 0) := "00001001"; -- 10
	constant D14	: std_logic_vector(7 downto 0) := "00100101"; -- 37
	constant D15   : std_logic_vector(7 downto 0) := "01001110"; -- 78
	
begin
	
	process(enable,sel)
	begin
		-- if the mux is enable
		if enable = '1' then
			
			-- The 16 to 1 Mux---
			case sel is
				when "0000" => q <= D0;
				when "0001" => q <= D1;
				when "0010" => q <= D2;
				when "0011" => q <= D3;
				when "0100" => q <= D4;
				when "0101" => q <= D5;
				when "0110" => q <= D6;
				when "0111" => q <= D7;
				when "1000" => q <= D8;
				when "1001" => q <= D9;
				when "1010" => q <= D10;
				when "1011" => q <= D11;
				when "1100" => q <= D12;
				when "1101" => q <= D13;
				when "1110" => q <= D14;
				when others => q <= D15;
				
			end case;
		
		-- the mux is disabled, output 0
		else 
			q <= D_OFF;
		end if;
	
	end process;	
		
end Behavioral;
