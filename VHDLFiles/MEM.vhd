----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2024 05:22:36 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM is
Port (  memWrite : in std_logic;
        aluResIn : in std_logic_vector(31 downto 0);
        rd2 : in std_logic_vector(31 downto 0);
        clk: in std_logic;
        en : in std_logic;
        memData : out std_logic_vector(31 downto 0);
        aluResOut  : out std_logic_vector(31 downto 0));
end MEM;

architecture Behavioral of MEM is
signal address : std_logic_vector(5 downto 0);
type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
signal ram: ram_type := (
others => x"00000000");

begin

process(clk)
begin
    if rising_edge(clk) then
    if en = '1' then
        if memWrite = '1' then
            ram(conv_integer(address)) <= rd2;
        end if;
     end if;
    end if;
    
    
end process;

 memData <= ram(conv_integer(address));
address <= AluResIn(7 downto 2);
aluResOut <= aluResIn;
memData <=  ram(conv_integer(address));

end Behavioral;
