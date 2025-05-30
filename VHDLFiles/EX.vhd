----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2024 04:32:20 PM
-- Design Name: 
-- Module Name: EX - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EX is
Port (  RD1 : in std_logic_vector(31 downto 0);
        RD2 : in std_logic_vector(31 downto 0);
        aluSrc : in std_logic;
        extImm : in std_logic_vector(31 downto 0);
        AluOp: in std_logic_vector(2 downto 0);
        pcPlus4: in std_logic_vector(31 downto 0);
        func : in std_logic_vector(5 downto 0);
        sa : in std_logic_vector(4 downto 0);
        

        zero : out std_logic;
        aluRes : out std_logic_vector(31 downto 0);
        branchAdress : out std_logic_vector(31 downto 0));
end EX;

architecture Behavioral of EX is
signal aluCtrl:std_logic_vector(2 downto 0);
signal resForMux: std_logic_vector(31 downto 0);
signal resFromAlu: std_logic_vector(31 downto 0);
signal extImmShift: std_logic_vector(31 downto 0);
begin

process (aluOp, func)
begin
  case aluOp is 
  --de tipul r
  when "10" =>
     case func is
     --sll
        when "000000" =>
            aluCtrl <= "011";
        when "100000" => 
            aluCtrl <= "000";
        when "100010" =>
            aluCtrl <= "001";
        when "100101" =>
            aluCtrl <= "010";
        when "101010" =>
            aluCtrl <= "101" ;
        when "000010" =>
            aluCtrl <= "100" ;
          
        --"100101"
        when others =>    
            aluCtrl <= "111";
     end case;
  when "01" =>
        aluCtrl <= "001";
  when "11" =>   
        aluCtrl <= "010";
  --00
  when others =>   
        aluCtrl <= "000";
  end case;
            
end process;

process(AluSrc)
begin
case AluSrc is
    when '0' => resForMux <= rd2;
    when '1' => resForMux <= extImm;
end case;
end process;


process(aluCtrl)
begin
case aluCtrl is
    when "000" => resFromAlu <= resForMux + rd1;
    
    when "001" => resFromAlu <= resForMux - rd1;

    when "010" => resFromAlu <= resForMux and rd1;
 
    when "011" => if unsigned(resForMux) < unsigned(rd1) then
                       resFromAlu <= x"00000001";
                  else
                       resFromAlu <= x"00000000";
                  end if;
    when "101" =>
            resFromAlu <= std_logic_vector(shift_left(unsigned(resForMux), to_integer(unsigned(sa)))); --numeric_std  
    when "100" =>
            resFromAlu <= std_logic_vector(shift_right(unsigned(resForMux), to_integer(unsigned(sa)))); --numeric_std  
                   
 --"110"
     when others => resFromAlu <= resForMux or rd1;
                                     
end case;

 if resFromAlu = 0 then
    zero <= '1';
 else 
     zero <= '0';
 end if;    
 
 aluRes <= resFromAlu;
                    
                    
end process;

branchAdress <= pcPlus4 + (extImm(29 downto 0) & "00");

end Behavioral;
