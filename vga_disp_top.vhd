----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:12:17 09/17/2014 
-- Design Name: 
-- Module Name:    vga_disp_top - Behavioral 
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

library UNISIM;
use UNISIM.VComponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL; 


entity vga_disp_top is
    Port ( fpga_clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  switches : in STD_LOGIC_VECTOR (7 downto 0);
			  buttons  : in STD_LOGIC_VECTOR (3 downto 0);
			  clk_lock : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
			  
			  data_out_bit : out  STD_LOGIC;
			  sync_data : out  STD_LOGIC;
			  clk_out : out  STD_LOGIC;
			  
			  segs : out  STD_LOGIC_VECTOR (6 downto 0);
           anodes : out  STD_LOGIC_VECTOR (3 downto 0);
           red : out  STD_LOGIC_VECTOR (2 downto 0);
           green : out  STD_LOGIC_VECTOR (2 downto 0);
           blue : out  STD_LOGIC_VECTOR (1 downto 0));
end vga_disp_top;

architecture Behavioral of vga_disp_top is

-------- SIGNALS ---------------------------------

signal clk_25  	    : std_logic;
signal clk_10  	    : std_logic; -- 10MHz
signal clk_10Hz_sig	 : std_logic;
signal hcount  	    : std_logic_vector(10 downto 0);
signal vcount  	    : std_logic_vector(10 downto 0);
signal blank   	    : std_logic; 
signal box_pos_sig    : std_logic_vector(9 downto 0);
signal counter_out    : STD_LOGIC_VECTOR(1 downto 0);
signal seven_seg_in   : std_logic_vector(15 downto 0);
signal DAC_in_sig     : std_logic_vector(15 downto 0);
signal DAC_load		 : std_logic;
signal DAC_sine 		 : std_logic_vector(7 downto 0);

--------------------------------------------------

----------------- ODR BUFFER CODE -----------

-- Place this code in the top-level HDL file
-- Before the 'begin' keyword

   signal sclk : std_logic; -- the output to the DAC
	signal clk_10_inv: std_logic;
  
-----------------------------------------------

------- COMPONENTS -------------------------------

component dcm_25
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;

COMPONENT vga_controller_640_60
	PORT(
		rst : IN std_logic;
		pixel_clk : IN std_logic;          
		HS : OUT std_logic;
		VS : OUT std_logic;
		hcount : OUT std_logic_vector(10 downto 0);
		vcount : OUT std_logic_vector(10 downto 0);
		blank : OUT std_logic
		);
END COMPONENT;

COMPONENT vga_disp
	PORT(
		blank : IN std_logic;
		hcount : IN std_logic_vector(10 downto 0);
		vcount : IN std_logic_vector(10 downto 0);
		disp_switches : IN std_logic_vector(1 downto 0);
		box_pos  : IN std_logic_vector(9 downto 0);	
		red : OUT std_logic_vector(2 downto 0);
		green : OUT std_logic_vector(2 downto 0);
		blue : OUT std_logic_vector(1 downto 0)
		);
END COMPONENT;

COMPONENT box_tracker
PORT(
	inital_pos : IN std_logic_vector(5 downto 0);
	move : IN std_logic_vector(3 downto 0);
	reset : IN std_logic;
	clk : IN std_logic;          
	box_pos : OUT std_logic_vector(9 downto 0)
	);
END COMPONENT;

COMPONENT count_to_4
	PORT(
		clock_in : IN std_logic;
		reset : IN std_logic;          
		counter_out : OUT std_logic_vector(1 downto 0)
		);
END COMPONENT;

COMPONENT box_pos_decoder
	PORT(
		box_pos : IN std_logic_vector(9 downto 0);          
		seven_seg_data_in : OUT std_logic_vector(15 downto 0)
		);
END COMPONENT;

COMPONENT seven_seg
	PORT(
		data : IN std_logic_vector(15 downto 0);
		mux_in : IN std_logic_vector(1 downto 0);          
		anode : OUT std_logic_vector(3 downto 0);
		segLED : OUT std_logic_vector(6 downto 0)
		);
END COMPONENT;

COMPONENT clk_10Hz
	PORT(
		clk_in : IN std_logic;
		reset : IN std_logic;          
		clk_out : OUT std_logic
		);
END COMPONENT;

COMPONENT dac_in
	PORT(
		clk_in : IN std_logic;
		reset : IN std_logic;
		data_in : IN std_logic_vector(15 downto 0);
		load : IN std_logic;          
		sync_data : OUT std_logic;
		data_out_bit : OUT std_logic
		);
END COMPONENT;

COMPONENT sine_wave
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		DAC : OUT std_logic_vector(7 downto 0);
		load : OUT std_logic
		);
END COMPONENT;

--------------------------------------------------

begin

	----------------- ODR BUFFER CODE -------------------
	
	-- Place the following after the 'begin' keyword
   clk_10_inv <= NOT clk_10;


   -- Clock forwarding circuit using the double data-rate register
   --        Spartan-3E/3A/6
   -- Xilinx HDL Language Template, version 14.5

   ODDR2_inst : ODDR2
   generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "SYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => sclk, -- 1-bit output data
      C0 => clk_10, -- 1-bit clock input
      C1 => clk_10_inv, -- 1-bit clock input
      CE => '1',  -- 1-bit clock enable input
      D0 => '0',   -- 1-bit data input (associated with C0)
      D1 => '1',   -- 1-bit data input (associated with C1)
      R => '0',    -- 1-bit reset input
      S => '0'     -- 1-bit set input
   );

   -- End of clock_forward_inst instantiation

	-- DCM, 25MHZ and 10MHZ
	U1 : dcm_25 PORT MAP(
		 CLK_IN1 => fpga_clk,
		 CLK_OUT1 => clk_25,
		 CLK_OUT2 => clk_10,
		 RESET  => reset,
		 LOCKED => clk_lock
	);
	
	-- VGA controller provided 
	U2 : vga_controller_640_60 PORT MAP(
		rst => reset ,
		pixel_clk => clk_25,
		HS => HS,
		VS => VS,
		hcount => hcount,
		vcount => vcount,
		blank => blank
	);
	
	-- The combinational logic that determines the screen output
	U3 : vga_disp PORT MAP(
		blank => blank,
		hcount => hcount,
		vcount => vcount,
		disp_switches => switches(1 downto 0),
		box_pos  => box_pos_sig,
		red => red,
		green => green,
		blue => blue 
	);
	
	-- The state machine that tracks the position of the box
	U4 : box_tracker PORT MAP(
		inital_pos => switches(7 downto 2),
		move => buttons(3 downto 0),
		reset => reset,
		clk => clk_10Hz_sig,
		box_pos => box_pos_sig
	);
	
	-- 2-bit Counter used cycle the anodes 
	U5 : count_to_4 PORT MAP(
		clock_in => clk_10,
		reset => reset,
		counter_out => counter_out 
	);
	
	-- Box position decoder
	U6 : box_pos_decoder PORT MAP(
		box_pos => box_pos_sig,
		seven_seg_data_in => seven_seg_in 
	);
	
	-- 7-segment display
	U7 : seven_seg PORT MAP(
		data => seven_seg_in,
		mux_in => counter_out,
		anode => anodes,
		segLED => segs
	);
	
	-- 10Hz Clock
	U8 : clk_10Hz PORT MAP(
		clk_in => clk_10,
		reset => reset,
		clk_out => clk_10Hz_sig
	);
	
	-- The DAC interface
	U9: dac_in PORT MAP(
		clk_in => clk_10,
		reset => reset,
		data_in => DAC_in_sig,
		load => DAC_load,
		sync_data => sync_data,
		data_out_bit => data_out_bit 
	);
	
	-- Sine Wave Generator
	U10: sine_wave PORT MAP(
		clk => clk_10,
		reset => reset,
		DAC => DAC_sine ,
		load => DAC_load
	);
---------------------------------------------------

	-- Concatanate the DAC control bits with the input from the sine wave generator
	DAC_in_sig <= "00000000" & DAC_sine;

	-- Clock signal sent off the board
	clk_out <= sclk;

end Behavioral;

