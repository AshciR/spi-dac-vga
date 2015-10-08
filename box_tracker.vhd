----------------------------------------------------------------------------------
-- Company: WPI
-- Engineer: Richard Walker
-- 
-- Create Date:    15:23:36 09/25/2014 
-- Design Name: 
-- Module Name:    box_tracker - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: This module tracks the current position of the yellow box	
--					 then provides the data at a 10 bit vector to the VGA display module 	

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

entity box_tracker is
    Port ( inital_pos : in  STD_LOGIC_VECTOR (5 downto 0);
           move : in  STD_LOGIC_VECTOR (3 downto 0);
			  reset: in STD_LOGIC;
			  clk  : in STD_LOGIC; 
           box_pos : out  STD_LOGIC_VECTOR (9 downto 0));
end box_tracker;

architecture Behavioral of box_tracker is

	---- COMPONENTS ----------
	
	COMPONENT position_counter
	PORT(
		clk : IN std_logic;
		dir : IN std_logic;
		en : IN std_logic;
		pre : IN std_logic;
		reset : IN std_logic;
		srt_pos : IN std_logic_vector(4 downto 0);          
		current_pos : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;

	--------- SIGNALS --------
	
	-- inital x & y positions 
	signal int_x_pos: std_logic_vector(4 downto 0); 
	signal int_y_pos: std_logic_vector(4 downto 0); 

	-- current x & y positions
	signal x_pos: std_logic_vector(4 downto 0) := "00000"; 
	signal y_pos: std_logic_vector(4 downto 0) := "00000";
	
	-------- MOVE BUTTON CONSTANTS --------
	constant UP:    std_logic_vector(3 downto 0) := "1000";
	constant RIGHT: std_logic_vector(3 downto 0) := "0100";
	constant DOWN:  std_logic_vector(3 downto 0) := "0010";
	constant LEFT:  std_logic_vector(3 downto 0) := "0001"; 

	-- Move process parameters
	constant UP_DIR:    std_logic_vector(1 downto 0) := "00";
	constant DOWN_DIR:  std_logic_vector(1 downto 0) := "01";
	constant LEFT_DIR:  std_logic_vector(1 downto 0) := "10";
	constant RIGHT_DIR: std_logic_vector(1 downto 0) := "11";	
	
	signal load_ctrl: std_logic;
	
	signal x_dir:  std_logic;
	signal y_dir:  std_logic;

	signal enable_x_count: std_logic;
	signal enable_y_count: std_logic;
	
	------ SETUP STATE MACHINE PARAMETERS ----
	type state_type is (init, load, button_wait, up_state, down_state, left_state, right_state);
	signal current_state, next_state : state_type;

begin
	
	-- Concatanates the x and y positions to create an output (x,y)
	box_pos <= x_pos & y_pos;
	
	-- Splices the intial position vector 
	-- into the x and y components 
	int_x_pos <= "00" & inital_pos(5 downto 3);
	int_y_pos <= "00" & inital_pos(2 downto 0);
	
	
	-- Counter used to track X-position
		U1 : position_counter PORT MAP(
		clk => clk,
		dir => x_dir ,
		en => enable_x_count,
		pre => load_ctrl,
		reset => reset,
		srt_pos => int_x_pos,
		current_pos => x_pos
	);
	
		-- Counter used to track Y-position
		U2 : position_counter PORT MAP(
		clk => clk,
		dir => y_dir,
		en => enable_y_count,
		pre => load_ctrl ,
		reset => reset ,
		srt_pos => int_y_pos,
		current_pos => y_pos
	);
	
	------------- STATE MACHINE STARTS HERE ------------
	
	-- Process block to keep track of the state memory
	state_memory: process(clk, reset)
	begin
		if reset = '1' then
			current_state <= init;
		elsif rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process state_memory;
	
	-- Process block to determine the next state 
	next_state_logic: process (current_state, move, x_pos, y_pos)
	begin
		
		case current_state is
			
			-- initialize the system, then go to the load state
			when init =>
			
				next_state <= load;
			
			-- load state sets the inital position of the block
			when load =>
				
				-- Set control to load
				load_ctrl <= '1';
			
				-- Enable the counters so they 
				-- get the inital value
				enable_x_count <= '1';
				enable_y_count <= '1';
				
				-- after loading the inital position, 
				-- go to the waiting on buttons state.
				next_state <= button_wait;
			
			-- Stay in this state until a button is pressed
			when button_wait =>
				
				-- disarm load control
				load_ctrl <= '0';
				
				-- Disable the x & y counters
				x_dir <= '0';
				enable_x_count <= '0';
				
				y_dir <= '0';
				enable_y_count <= '0';
				
				-- UP was pressed
				if move = UP then
				
					-- if the y-pos is 0, then you can't go up any further
					case y_pos is
						when "00000" => next_state <= button_wait;
						when others => next_state <= up_state;
					end case;
				
				-- DOWN WAS PRESSED
				elsif move = DOWN then
					
					-- if the y-pos is 19, then you can't go down any further
					case y_pos is
						when "10011" => next_state <= button_wait;
						when others => next_state <= down_state;
					end case;
				
				-- LEFT WAS PRESSED
				elsif move = LEFT then
					
					-- if the x-pos is 0, then you can't go left any further
					case x_pos is
						when "00000" => next_state <= button_wait;
						when others => next_state <= left_state;
					end case;
					
				-- RIGHT WAS PRESSED
				elsif move = RIGHT then
				
					-- if the x-pos is 19, then you can't go right any further 
					case x_pos is
						when "10011" => next_state <= button_wait;
						when others => next_state <= right_state;
					end case;
					
				-- NO BUTTON WAS PRESSED		
				else 
					
					-- the move button wasn't pressed so keep the current position
					next_state <= button_wait;
					
				end if;
				
			when up_state =>
				
				-- tell the box to move up
				y_dir <= '0';
				enable_y_count <= '1';
				
				next_state <= button_wait;
					
			when down_state =>
				
				-- tell the box to move down
				y_dir <= '1';
				enable_y_count <= '1';
			
				next_state <= button_wait;			
				
			when left_state =>
					
				-- tell the box to move left
				x_dir <= '0';
				enable_x_count <= '1';
			
				next_state <= button_wait;
					
			when right_state =>
				
				-- tell the box to move right
				x_dir <= '1';
				enable_x_count <= '1';
				
				next_state <= button_wait;
						
		end case; -- end current_state case
	
	end process next_state_logic;

end Behavioral;

