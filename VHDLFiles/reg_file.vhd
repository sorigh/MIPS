----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2024 05:19:24 PM
-- Design Name: 
-- Module Name: reg_file - Behavioral
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

entity reg_file is
port ( 
clk : in std_logic;
ra1 : in std_logic_vector(4 downto 0);
ra2 : in std_logic_vector(4 downto 0);
wa : in std_logic_vector(4 downto 0);
wd : in std_logic_vector(31 downto 0);
regwr : in std_logic;
rd1 : out std_logic_vector(31 downto 0);
rd2 : out std_logic_vector(31 downto 0));
end reg_file;

architecture Behavioral of reg_file is
type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
signal reg_file : reg_array:= (
        1 => X"00000002",
        2 => X"00000001",
        3 => X"00000003",
        4 => X"00000004",
        5 => X"00000005",
       others => X"00000000");
begin

process(clk)
begin
    if rising_edge(clk) then
        if regwr = '1' then
            reg_file(conv_integer(wa)) <= wd;
        end if;
    end if;
end process;

rd1 <= reg_file(conv_integer(ra1));
rd2 <= reg_file(conv_integer(ra2));
end Behavioral;
