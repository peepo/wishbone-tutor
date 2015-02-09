----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:33:02 07/30/2013 
-- Design Name: 
-- Module Name:    logibone_wishbone - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work ;
use work.logi_wishbone_pack.all ;
use work.logi_virtual_components_pack.all ;

entity LED is
port( OSC_FPGA : in std_logic;

		--onboard
--		PB : in std_logic_vector(1 downto 0);
		SW : in std_logic_vector(1 downto 0);
		LED : out std_logic_vector(1 downto 0);	
		
		--i2c
		SYS_SCL, SYS_SDA : inout std_logic ;
		
		--spi
		SYS_SPI_SCK, RP_SPI_CE0N, SYS_SPI_MOSI : in std_logic ;
		SYS_SPI_MISO : out std_logic
);
end LED;

architecture Behavioral of LED is

	component clock_gen
	port
	(-- Clock in ports
		CLK_IN1           : in     std_logic;
		-- Clock out ports
		CLK_OUT1          : out    std_logic;
		-- Status and control signals
		LOCKED            : out    std_logic
	);
	end component;

	-- syscon
	signal sys_reset, sys_clk, clock_locked : std_logic ;
	signal clk_100Mhz : std_logic ;

	-- wishbone intercon signals
	signal intercon_wrapper_wbm_address :  std_logic_vector(15 downto 0);
	signal intercon_wrapper_wbm_readdata :  std_logic_vector(15 downto 0);
	signal intercon_wrapper_wbm_writedata :  std_logic_vector(15 downto 0);
	signal intercon_wrapper_wbm_strobe :  std_logic;
	signal intercon_wrapper_wbm_write :  std_logic;
	signal intercon_wrapper_wbm_ack :  std_logic;
	signal intercon_wrapper_wbm_cycle :  std_logic;

	signal intercon_leds0_wbm_address :  std_logic_vector(15 downto 0);
	signal intercon_leds0_wbm_readdata :  std_logic_vector(15 downto 0);
	signal intercon_leds0_wbm_writedata :  std_logic_vector(15 downto 0);
	signal intercon_leds0_wbm_strobe :  std_logic;
	signal intercon_leds0_wbm_write :  std_logic;
	signal intercon_leds0_wbm_ack :  std_logic;
	signal intercon_leds0_wbm_cycle :  std_logic;
	
	signal led0_cs : std_logic ;

	signal virtual_led : std_logic_vector(15 downto 0) ;

begin


---------------------------------------------------------------------
-- Syscon
-- The Syscon generats all the system clocks and reset of the reset of the architecture
---------------------------------------------------------------------

pll0 : clock_gen
  port map
   (-- Clock in ports
    CLK_IN1 => OSC_FPGA,
    -- Clock out ports
    CLK_OUT1 => clk_100Mhz,
    -- Status and control signals
    LOCKED => clock_locked);

sys_clk <= clk_100Mhz;


-------------------------------------------------------------
-- Instanciation of the Wishbone Master
-- ----------------------------------------------------------
mem_interface0 : spi_wishbone_wrapper
		port map(
			-- Global Signals
			gls_reset => sys_reset,
			gls_clk   => sys_clk,
			
			-- SPI signals
			mosi => SYS_SPI_MOSI,
			miso => SYS_SPI_MISO,
			sck => SYS_SPI_SCK,
			ss => RP_SPI_CE0N,
			
			  -- Wishbone interface signals
			wbm_address    => intercon_wrapper_wbm_address,  -- Address bus
			wbm_readdata   => intercon_wrapper_wbm_readdata,  -- Data bus for read access
			wbm_writedata 	=> intercon_wrapper_wbm_writedata,  -- Data bus for write access
			wbm_strobe     => intercon_wrapper_wbm_strobe,                      -- Data Strobe
			wbm_write      => intercon_wrapper_wbm_write,                      -- Write access
			wbm_ack        => intercon_wrapper_wbm_ack,                      -- acknowledge
			wbm_cycle      => intercon_wrapper_wbm_cycle                       -- bus cycle in progress
			);



-- Intercon -----------------------------------------------------------
-- will be generated automatically in the future
-- The intercon is architecture specific and takes care of wishbone signals routing
-- to the slaves. It generates a set of wishbone signals for each of the slaves.
-- This intercon has to be written for each architecture.


-- First part generates a Chip select for each of the slaves according to the memory map
led0_cs <= '1' when intercon_wrapper_wbm_address(15 downto 0) = "0000000000000000" else
				'0' ;



-- Second part generate the wishbone signals for each slaves. Control signals depends on the
-- previsously generated chip select
intercon_leds0_wbm_address <= intercon_wrapper_wbm_address ;
intercon_leds0_wbm_writedata <= intercon_wrapper_wbm_writedata ;
intercon_leds0_wbm_write <= intercon_wrapper_wbm_write and led0_cs ;
intercon_leds0_wbm_strobe <= intercon_wrapper_wbm_strobe and led0_cs ;
intercon_leds0_wbm_cycle <= intercon_wrapper_wbm_cycle and led0_cs ;

-- The third part takes care of the muxing of the readdata bus of the wishbone. This
-- bus is controlled by the slave activated by the generated chip select. 
intercon_wrapper_wbm_readdata	<= intercon_leds0_wbm_readdata when led0_cs = '1' else
											intercon_wrapper_wbm_address ;
											
											
--	The fourth part takes care of the muxing of the ack signal generated by the slaves.
-- It routes the selected slave ack signal to the master ack input										
intercon_wrapper_wbm_ack	<= intercon_leds0_wbm_ack when led0_cs = '1' else
										'0' ;
									      
-----------------------------------------------------------------------
-- Instanciation of the slaves
-- Each slave is instatiated and connected to its own wishbone signals
-----------------------------------------------------------------------
leds0 : logi_virtual_led
	 port map
	 (
		  -- Syscon signals
		  gls_reset   => sys_reset ,
		  gls_clk     => sys_clk ,
		  -- Wishbone signals
		  wbs_address     =>  intercon_leds0_wbm_address ,
		  wbs_writedata => intercon_leds0_wbm_writedata,
		  wbs_readdata  => intercon_leds0_wbm_readdata,
		  wbs_strobe    => intercon_leds0_wbm_strobe,
		  wbs_cycle     => intercon_leds0_wbm_cycle,
		  wbs_write     => intercon_leds0_wbm_write,
		  wbs_ack       => intercon_leds0_wbm_ack,
		 
		  led => virtual_led
	 );

-------------------------------------------------------------------
-- Connection of the logic
-- This part connect all the glue logic
-------------------------------------------------------------------	
   LED(0) <= SW(0);
   LED(1) <= SW(1);
 
   virtual_led(0) <= SW(0);
   virtual_led(1) <= SW(1);						

end Behavioral;

