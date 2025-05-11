----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2024 04:27:41 PM
-- Design Name: 
-- Module Name: IFetch - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFetch is
Port (
clk: in std_logic;
en:in std_logic;
rst: in std_logic;
jump: in std_logic;
PCSrc: in std_logic;
JumpAdr: in std_logic_vector(31 downto 0);
BranchAdr: in std_logic_vector(31 downto 0);
instruction: out std_logic_vector(31 downto 0);
PC:out std_logic_vector(31 downto 0)
 );
end IFetch;

architecture Behavioral of IFetch is
signal PCsum:std_logic_vector(31 downto 0);
signal branchRez:std_logic_vector(31 downto 0);
--signal branch2Rez:std_logic_vector(31 downto 0);
signal PCin:std_logic_vector(31 downto 0);
signal PCout:std_logic_vector(31 downto 0);
type mem_rom is array(0 to 32)of std_logic_vector(31 downto 0);
signal rom: mem_rom:=(
-- aici cod
      0=>B"100011_001010_000000_00000000000000", -- 8CA00000 lw $t0, 0($0) -- incarcat valori 
      1=>B"100011_001001_000000_00000000000100", -- 8C900004  lw $t1, 4($0) 
      2=>B"000000_01001_01010_01011_00010_000000", -- 00095880 sll $t3, $t1, 2
      3=>B"001000_01001_01010_1111111111111111", -- 2129FFFF addi $t1, $t1, -1 
      4=>B"010101_00000_01101_0000000000000001",-- 240D0001 addiu //li $t5, 1, addiu $13. $0, 00..0
      
      5=>B"000100_01001_00000_0000000000010000",-- 240D0001 beq//beqz $t1, end_sort  
      6=>B"010101_00000_01101_0000000000000000",-- 240D0000 addiu //li $t5, 0 -- resetare flag de swap la inceputul fiecarei iteratii de outer loop
      
      7=>B"001111_00000001010_001000000000001",-- 3C011001 lui// la $t2, array
      8=>B"001001_00000_01001_0000000000000000",-- 24090000 addiu //li $t1, 0 -- inceput de array
      9=>B"100011_001100_001010_00000000000000",-- 8D4C0000 lw $t4, ($t2) 
      10=>B"100011_001101_001010_00000000000100", -- 8D4D0004 lw $t5, 4($t2) --incarca urmatoarea valoare
      
      11=>B"000000_01101_01100_00001_00000_101010",-- 01AC082A slt//bgt $t4, $t5, swap_values 
      
      12=>B"001000_01010_01010_0000000000000100", -- 214A0004 addi $t2, $t2, 4 --urmatoarea pereche de valori
      13=>B"000100_01010_00000_1111111111111010", -- 1140001A beq//beqz $t2, inner_loop 00 verifica sfarsit de array
      14=>B"000010_00000100000000000000000111",-- 08100007 j outer_loop -- continuare outer loop
      
     
      15=>B"101011_01010_01100_0000000000000000", -- AD4C0000 sw $t5, 0($t2) -- urmatoarea valoare la pozitia asta
      16=>B"101011_01010_01100_0000000000000100",-- AD4C0004 sw $t4, 4($t2)  -- valoarea curenta la pozitia urmatoare 
      17=>B"001000_01010_00010_0000000000000100", -- 21420004 addi $t2, $t2, 4 --urmatoarea pereche
      18=>B"000100_01010_00000_1111111111111010", -- 1140FFFA beq//beqz $t2, inner_loop
      19=>B"000010_00000100000000000000000111",-- 08100007 j outer_loop  -- continuare outer loop
      
      20=>B"001111_00000000010001000000000001", --3C011001 lui//la $t2, array -- reincarcare adresa pentru printare
      21=>B"001001_00000000100000000000000001",-- 24020001 addiu //li $v0, 1  -- printare
      22=>B"100011_000100_000000_00000000000000", -- 8C400000 lw $a0, ($t2)   
      23=>B"000000_00000000000000000000001100",-- 0000000C syscall
      
      
      24=>B"000100_00100_00000_0000000000000010",-- 10800002 beq//beqz $a0, end_print_loop  -- daca se ajunge la 0, se iasa din loop
      
      25=>B"001000_00010_00010_0000000000000100",-- 214A0004 addi $t2, $t2, 4 --urmatorul element
      26=>B"000010_00000100000000000000011010", -- 0810001A j print_loop  --continuand printarea elementelor
      
      27=>B"001001_00000_00010_0000000000001010",-- 2402000A addiu //li $v0, 10  --pregatire de iesire
      28=>B"000000_00000000000000000000001100", -- 0000000C syscall
      
      others=>B"00000000000000000000000000000000"
);

begin

--proces modificare pc in functie daca exista jump sau nu
branchRez<=PCsum when PCSrc='0' else BranchAdr;
PCin<=branchRez when Jump='0' else JumpAdr;

--bistabil PC
process(clk,rst)
begin
if rst='1' then
   PCout<=(others=>'0');
else
   if clk='1' and clk'event then
      if en='1'then
         PCout<=PCin;
      end if;
   end if;
end if;
end process;


--sumator
PCsum<= PCout+X"00000004";

PC<=PCsum;
--memorie rom
instruction<=rom(conv_integer(PCout(6 downto 2)));


end Behavioral;