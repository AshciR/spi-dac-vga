----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: RIchard Walker
-- 
-- Create Date:    19:24:34 08/30/2014 
-- Design Name: 
-- Module Name:    seven_seg - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_seg is
    Port ( data   : in  STD_LOGIC_VECTOR (15 downto 0);
			  mux_in : in  STD_LOGIC_VECTOR (1 downto 0);
			  anode  : out STD_LOGIC_VECTOR (3 downto 0);
           segLED : out STD_LOGIC_VECTOR (6 downto 0));
end seven_seg;

architecture Behavioral of seven_seg is

-- Defining the constants
-- g f e d c b a

	constant zero  : std_logic_vector(6 downto 0) := "1000000";
	constant one   : std_logic_vector(6 downto 0) := "1111001";
	constant two   : std_logic_vector(6 downto 0) := "0100100";
	constant three : std_logic_vector(6 downto 0) := "0110000";
	constant four  : std_logic_vector(6 downto 0) := "0011001";
	constant five  : std_logic_vector(6 downto 0) := "0010010";
	constant six   : std_logic_vector(6 downto 0) := "0000010";
	constant seven : std_logic_vector(6 downto 0) := "1111000";
	constant eight : std_logic_vector(6 downto 0) := "0000000";
	constant nine  : std_logic_vector(6 downto 0) := "0010000";
	constant a 		: std_logic_vector(6 downto 0) := "0001000";
	constant b 		: std_logic_vector(6 downto 0) := "0000011";
	constant c  	: std_logic_vector(6 downto 0) := "1000110";
	constant d 		: std_logic_vector(6 downto 0) := "0100001";
	constant e 		: std_logic_vector(6 downto 0) := "0000110";
	constant f  	: std_logic_vector(6 downto 0) := "0001110";
	constant off   : std_logic_vector(6 downto 0) := "1111111";
	
-- Splits the 16-bit bus into 4 4-bit parts.
-- Each part will serve at the number representation for an anode
-- AN3 AN2 AN1 AN0
	
	alias data_3 : std_logic_vector(3 downto 0) is data (15 downto 12);
	alias data_2 : std_logic_vector(3 downto 0) is data (11 downto 8 );
	alias data_1 : std_logic_vector(3 downto 0) is data ( 7 downto 4 );
	alias data_0 : std_logic_vector(3 downto 0) is data ( 3 downto 0 );	

	-- the output of mux; input to the seg_decoder 
	signal data_to_seg : std_logic_vector (3 downto 0); 

begin
	
	-- Selects the appropiate input data bus and 
	-- turns anode corresponding anode on
	process(mux_in, data_3, data_2, data_1, data_0)
	begin
		case mux_in is
			when "11" =>
				data_to_seg <= data_3;
				anode <= "0111";
			when "10" => 
				data_to_seg <= data_2;
				anode <= "1011";
			when "01" => 
				data_to_seg <= data_1;
				anode <= "1101";
			when others => 
				data_to_seg <= data_0;
				anode <= "1110";
		end case;	
	end process;
	
	-- Decodes the data provided by the mux
	process(data_to_seg) 
	begin
		case data_to_seg is
			when "0000" => segLED <= zero;
			when "0001" => segLED <= one;
			when "0010" => segLED <= two;
			when "0011" => segLED <= three;
			when "0100" => segLED <= four;
			when "0101" => segLED <= five;
			when "0110" => segLED <= six;
			when "0111" => segLED <= seven;
			when "1000" => segLED <= eight;
			when "1001" => segLED <= nine;
			when "1010" => segLED <= a;
			when "1011" => segLED <= b;
			when "1100" => segLED <= c;
			when "1101" => segLED <= d;
			when "1110" => segLED <= e;
			when "1111" => segLED <= f;
			when others => segLED <= off;
		end case; 
	end process; 
	
end Behavioral;

