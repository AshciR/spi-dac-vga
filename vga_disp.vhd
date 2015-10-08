----------------------------------------------------------------------------------
-- Company: WPI	
-- Engineer: Richard Walker
-- 
-- Create Date:    21:31:28 09/17/2014 
-- Design Name: 
-- Module Name:    vga_disp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: VGA Display Module
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_disp is
    Port ( blank : in  STD_LOGIC;
           hcount : in  STD_LOGIC_VECTOR (10 downto 0);
           vcount : in  STD_LOGIC_VECTOR (10 downto 0);
           disp_switches : in STD_LOGIC_VECTOR (1 downto 0);
			  box_pos  : IN std_logic_vector(9 downto 0);
			  red : out  STD_LOGIC_VECTOR (2 downto 0);
           green : out  STD_LOGIC_VECTOR (2 downto 0);
           blue : out  STD_LOGIC_VECTOR (1 downto 0));
end vga_disp;

architecture Behavioral of vga_disp is

	------------------------------------------------------------------------
	-- CONSTANTS
	------------------------------------------------------------------------

	-- Screen displays for various switches
	constant BLUE_C  : std_logic_vector(1 downto 0) := "01"; -- 1
	constant GREEN_C  : std_logic_vector(1 downto 0) := "10"; -- 2
	constant RECT_C  : std_logic_vector(1 downto 0) := "11"; -- 3

	-- Color Constants [RGB]
	constant WHITE_PX   : std_logic_vector(7 downto 0) := "11111111"; 
	constant BLACK_PX   : std_logic_vector(7 downto 0) := "00000000";
	constant YELLOW_PX  : std_logic_vector(7 downto 0) := "11111100";
	constant BLUE_PX 	  : std_logic_vector(7 downto 0) := "00000011";
	constant RED_PX 	  : std_logic_vector(7 downto 0) := "11100000";
	constant GREEN_PX   : std_logic_vector(7 downto 0) := "00011100";

	-- rectangle boundary conditions
	constant X1: std_logic_vector(10 downto 0) := "00000001001"; -- 9
	constant X2: std_logic_vector(10 downto 0) := "01001110110"; -- 630
	constant Y1: std_logic_vector(10 downto 0) := "00000001001"; -- 9
	constant Y2: std_logic_vector(10 downto 0) := "00111010110"; -- 470

	-- yellow block parameters
	constant BK_X: std_logic_vector(10 downto 0) := "00000100000"; -- block width = 32px 
	constant BK_Y: std_logic_vector(10 downto 0) := "00000011000"; -- block height = 24px

	-- Current positions for block at (x,y)
	signal x_pos: std_logic_vector(15 downto 0); 
	signal y_pos: std_logic_vector(15 downto 0); 

	-- Signal to represent pixel color
	signal color: std_logic_vector(7 downto 0);

begin
	
	-- Sets the pins on the VGA depending on 
	-- the current color of the pixel
	red   <= color(7 downto 5);
	green <= color(4 downto 2);
	blue  <= color(1 downto 0);
	
	
	-- Sets the position of the box
	process (box_pos)
	begin
		
		x_pos <= box_pos(9 downto 5) * BK_X;	-- x-coordinate * box width
		y_pos <= box_pos(4 downto 0) * BK_Y;	-- y-coordinate * box height
		
	end process;
	
	-- Changes the screen to be either blue or green
	-- depending on the switch input
	process (disp_switches, blank, hcount, vcount, x_pos, y_pos)
	begin
		if blank ='0' then
			case disp_switches is
				when BLUE_C => color <= BLUE_PX;		-- Make the screen blue
				when GREEN_C => color <= GREEN_PX;  -- Make the screen green
				
				when RECT_C => -- Draw a white rectangle on the screen that is 10px from each edge
					-- Check if vcount is on 9th row or the 470th row --
					if (vcount = Y1) OR (vcount = Y2) then
						-- Draw a white horizontal line starting from the 10px
						if (hcount >= X1) AND (hcount <= X2) then
							color <= WHITE_PX;
						else
							color <= BLACK_PX;
						end if;
					
					-- If vcount_sig is between the 10th row and the 470th row	
					elsif (vcount >= Y1) AND (vcount < Y2) then
						-- Draw white pixel only on 9th coloumn and 630th column --
						if (hcount = X1) OR (hcount = X2) then
							color <= WHITE_PX;
						else
							color <= BLACK_PX;
						end if;
					
					-- It's not on the perimeter of the rectgangle, set it to black
					else
						color <= BLACK_PX;
					end if;	-- END DRAW RECTANGLE IF
				
				-- This option is used for displaying the moving box game.
				when others =>
					
					-- if the vcount and hcount are more than the starting position and 
					-- less than (the start position + the height & width) of the box
					-- then that's the area that needs to be filled.
					if ( (vcount >= y_pos) AND (vcount < (y_pos + BK_Y)) AND
					     (hcount >= x_pos) AND (hcount < (x_pos + BK_X)) ) then
						color <= YELLOW_PX;
					else
						color <= BLACK_PX;
					end if;
			end case; -- End the switch-screen case
		
		else -- blank is on, so make the screen black 
			color <= BLACK_PX;
		end if;
	end process;

end Behavioral;

