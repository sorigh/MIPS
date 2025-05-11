----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2024 11:58:45 AM
-- Design Name: 
-- Module Name: test_env - Behavioral
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

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
signal pcSrc: std_logic;
--signals for reg_file
signal wd : std_logic_vector(31 downto 0);

--signals for ifetch
signal digits:std_logic_vector(31 downto 0):=(others=>'0');
signal en_if:std_logic;
signal instruction:std_logic_vector(31 downto 0);
signal PC:std_logic_vector(31 downto 0);
signal branchAdr:std_logic_vector(31 downto 0);

--signals for UC
signal instr : std_logic_vector(5 downto 0);
signal regDest : std_logic;
signal extOp : std_logic;
signal aluSrc : std_logic;
signal branch :  std_logic;
signal jump :  std_logic;
signal aluOp : std_logic_vector(2 downto 0);
signal memWrite : std_logic;
signal memToReg : std_logic;
signal regWrite : std_logic;

--signals for ID
 signal rd1 : std_logic_vector(31 downto 0);
 signal rd2 : std_logic_vector(31 downto 0);
 signal sa : std_logic_vector(4 downto 0);
 signal func : std_logic_vector(5 downto 0);
 signal ext_imm : std_logic_vector(31 downto 0);


--signals for ex outputs
 signal zero : std_logic;
 signal aluRes : std_logic_vector(31 downto 0);
 signal branchAdress : std_logic_vector(31 downto 0);
 signal jumpAdress : std_logic_vector(31 downto 0);
 
 --signals for MEM outputs
 signal memData : std_logic_vector(31 downto 0);
 signal aluResOut  : std_logic_vector(31 downto 0);
 
 
component MPG
    Port ( en : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0)
          );
end component;


component IFetch
    Port ( clk: in std_logic;
           en:in std_logic;
           rst: in std_logic;
           Jump: in std_logic;
           PCSrc: in std_logic;
           JumpAdr: in std_logic_vector(31 downto 0);
           BranchAdr: in std_logic_vector(31 downto 0);
           instruction: out std_logic_vector(31 downto 0);
           PC:out std_logic_vector(31 downto 0)
     );
end component;
component ID
     Port ( clk:in std_logic;
            validWrt:in std_logic;
            regWrite : in std_logic;
            regDst : in std_logic;
            extOp : in std_logic;
            instr : in std_logic_vector(25 downto 0);
            wd : in std_logic_vector(31 downto 0);
            
            rd1 : out std_logic_vector(31 downto 0);
            rd2 : out std_logic_vector(31 downto 0);
            ext_imm : out std_logic_vector(31 downto 0);
            func : out std_logic_vector(5 downto 0);
            sa : out std_logic_vector(4 downto 0)); --se duce in ex 
        
 end component;
 
 component UC
     Port ( instr : in std_logic_vector(5 downto 0);
            regDest : out std_logic;
            extOp : out std_logic;
            aluSrc : out std_logic;
            branch : out std_logic;
            jump : out std_logic;
            aluOp : out std_logic_vector(2 downto 0);
            memWrite : out std_logic;
            memToReg : out std_logic;
            regWrite : out std_logic);
     
 end component;
 
 component EX
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
 end component;
 
 
 component MEM
 Port (  memWrite : in std_logic;
        aluResIn : in std_logic_vector(31 downto 0);
        rd2 : in std_logic_vector(31 downto 0);
        clk: in std_logic;
        en : in std_logic;
        memData : out std_logic_vector(31 downto 0);
        aluResOut  : out std_logic_vector(31 downto 0));
  end component;
begin

--portmap ssd
display:SSD port map (
clk=>clk,
digits=>digits,
an=>an,
cat=>cat);



--portmap IFETCH
InstructionFetch:IFetch port map
(
clk=>clk,
en=>en_if, --en facut prin mpg, legat de btn(0)
rst=>btn(1),
Jump=>Jump,
PCSrc=>PcSrc,
JumpAdr=>jumpAdress,
BranchAdr=>branchAdress,
instruction=>instruction,
PC=>PC -- in ex
);

--portmap mpg pentru ifetch
btn_IFETCH:MPG port map
(
btn=>btn(0),
clk=>clk,
en=>en_if
);
-- ifetch controlat de switch(7)
--in pc se afla pc+4

--portmap ID
Instruction_Decoder: ID port map
(
    clk => clk,
    validWrt => en_if,
    regWrite => regWrite, -- dus in UC
    regDst  => regDest, --dus in UC
    extOp  => extOp, -- dus in UC
    instr => instruction(25 downto 0), 
    wd => wd,
    rd1 => rd1, --output din id dus in EX
    rd2 => rd2, -- output din ID dus in MEM
    ext_imm => ext_imm,
    func => func, 
    sa => sa
);


Control_Unit:UC port map
(
    instr => instruction(31 downto 26),
    regDest => regDest,--id
    extOp => extOp, -- id
    aluSrc => aluSrc, --merge in ex
    branch => branch,
    jump => jump,
    aluOp => aluOp, --merge in ex
    memWrite => memWrite,
    memToReg => memToReg,
    regWrite => regWrite -- id
);


--portmap EX
Execution_Unit:EX port map
(
    --in
    RD1 => rd1,
    RD2=> rd2,
    aluSrc => aluSrc, --din uc
    extImm => ext_imm, --din uc
    AluOp => aluOp,
    pcPlus4=> PC, --din ifetch
    func => func, -- din id
    sa => sa, -- din id
    
    --out
    zero => zero,
    aluRes => aluRes,
    branchAdress => branchAdress
);



--portmap Mem
Memory_Unit: MEM port map
(
    memWrite => memWrite, --din uc
    aluResIn =>aluRes, -- din ex
    rd2 => RD2, -- DIN ID
    clk => clk,
    en => en_if,
    memData => memData,
    aluResOut => aluResOut
);

with sw(7 downto 5) select
digits <= Instruction when "000",
          pc when "001",
          rd1 when "010",
          rd2 when "011",
          ext_Imm when "100",
          ALURes when "101",
          MemData when "110",
          WD when "111",
          (others => 'X') when others;


--digits<=instruction when sw(7)='0' else PC;

          
-- mux wb (write back) care intra in reg
wd <= memData when memToReg = '1' else ALUResOut;

jumpAdress<=PC(31 downto 28)&instruction(25 downto 0)&"00";

PcSrc <= branch and zero;

end Behavioral;
