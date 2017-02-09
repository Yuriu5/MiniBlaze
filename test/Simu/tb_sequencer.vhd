library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tb_sequencer_pkg is

   -- Constant declaration
   constant D_WIDTH        : integer   := 32;   
   constant SIZE_MEM       : integer   := 4;
   constant c_zero         : std_logic_vector(D_WIDTH-1 downto 0) := (others => '0');
   constant NB_COL         : integer   := 4;
   constant COL_WIDTH      : integer   := D_WIDTH/4;
   constant C_PERIOD       : time      := 8 ns;
   constant SIZE           : natural   := 2**SIZE_MEM;
   constant NB_WAIT_CLK    : integer   := 100;

   type ram_type is array (SIZE-1 downto 0) of std_logic_vector (D_WIDTH-1 downto 0);

   function instr_A(rD,rA,rB : integer; opcode : std_logic_vector(5 downto 0)) return std_logic_vector;
   function instr_B(rD,rA,imm : integer; opcode : std_logic_vector(5 downto 0)) return std_logic_vector;
   function instr_A_bsl(rD,rA,rB : integer; opcode : std_logic_vector(5 downto 0);S,T : std_logic) return std_logic_vector;  
   function instr_B_bsl(rD,rA,imm : integer; opcode : std_logic_vector(5 downto 0);S,T : std_logic) return std_logic_vector;
   
   
   
   type data_test is
      record
         program : ram_type;
         result  : std_logic_vector(D_WIDTH-1 downto 0);
      end record;
   
   constant N : integer := 12;   
   type vect_data_test is array(0 to N-1) of data_test;
   constant c_test : vect_data_test := (
      0 => ((  -- ADD Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A( 2, 0, 1, "000000"),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"00120000",
               15 => x"00003456",
               others => (others => '0')),
            x"00123456"),
      1 => (( -- RSUB Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A( 2, 0, 1, "000001"),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"00000000",
               15 => x"00000004",
               others => (others => '0')),
            x"00000004"),
      2 => (( -- ADDC Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A( 5, 5, 0, "000001"),  -- Set carry to one
               3 => instr_A( 2, 0, 1, "000010"),  -- Instruction to test (result in r2)
               4 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               5 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"00003456",
               15 => x"00120000",
               others => (others => '0')),
            x"00123457") ,            
      3 => (( -- RSUBC Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A( 5, 5, 0, "000001"),  -- Set carry to one
               3 => instr_A( 2, 0, 1, "000011"),  -- Instruction to test (result in r2)
               4 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               5 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"FFFFFFFF",
               15 => x"00120000",
               others => (others => '0')),
            x"00120001"),
      4 => (( -- ADDK Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A( 5, 5, 0, "000100"),  -- Set carry to one
               3 => instr_A( 2, 0, 1, "000011"),  -- Instruction to test (result in r2)
               4 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               5 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"FFFFFFFF",
               15 => x"00120000",
               others => (others => '0')),
            x"00120000")      ,
      5 => (( -- CMP Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A( 2, 0, 1, "000101"),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"00000012",
               15 => x"00000011",
               others => (others => '0')),
            x"80000000"),
      6 => (( -- ADDI Rd,Ra,Imm
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_B( 2, 0, 1544, "001000"),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"10305070",
               15 => x"00000011",
               others => (others => '0')),
            x"10305678"),
      7 => (( -- MUL Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A( 2, 0, 1, "010000"),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"00001234",
               15 => x"00010000",
               others => (others => '0')),
            x"12340000")   ,
      8 => (( -- BSRA Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A_bsl( 2, 0, 1, "010001",'0','1'),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"FFF12345",
               15 => x"00000004",
               others => (others => '0')),
            x"FFFF1234"),
      9 => (( -- BSLL Rd,Ra,Rb
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_A_bsl( 2, 0, 1, "010001",'1','0'),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"FFF12345",
               15 => x"00000004",
               others => (others => '0')),
            x"FF123450"),
      10 => (( -- MULI Rd,Ra,Imm
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_B( 2, 0, 5, "011000"),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"00001234",
               15 => x"00010000",
               others => (others => '0')),
            x"00005B04") , 
      11 => (( -- BSRLI Rd,Ra,Imm
               0 => instr_B( 0, 4, 56, "111010"), -- Load *(0x18) into r0
               1 => instr_B( 1, 4, 60, "111010"), -- Load *(0x1C) into r1
               2 => instr_B_bsl( 2, 0, 6, "011001",'0','0'),  -- Instruction to test (result in r2)
               3 => instr_B( 2, 4, 52, "111110"), -- Store r2 at addr 0x14
               4 => instr_B( 0, 0, 0, "101110"),  -- Jump at 0x10 (while(1))
               13 => (others => '0'),
               14 => x"01001234",
               15 => x"00010000",
               others => (others => '0')),
            x"00040048")            
   );
   
end tb_sequencer_pkg;

package body tb_sequencer_pkg is

   function instr_A(rD,rA,rB : integer; opcode : std_logic_vector(5 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(31 downto 0) := (others => '0');
   begin
      result(31 downto 26) := opcode;
      result(25 downto 21) := std_logic_vector(to_unsigned(rD,5));
      result(20 downto 16) := std_logic_vector(to_unsigned(rA,5));
      result(15 downto 11) := std_logic_vector(to_unsigned(rB,5));
      
      return result;
   end function;
   
   function instr_B(rD,rA,imm : integer; opcode : std_logic_vector(5 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(31 downto 0) := (others => '0');
   begin
      result(31 downto 26) := opcode;
      result(25 downto 21) := std_logic_vector(to_unsigned(rD,5));
      result(20 downto 16) := std_logic_vector(to_unsigned(rA,5));
      result(15 downto  0) := std_logic_vector(to_unsigned(imm,16));
      
      return result;
   end function;

   function instr_A_bsl(rD,rA,rB : integer; opcode : std_logic_vector(5 downto 0);S,T : std_logic) return std_logic_vector is
   variable result : std_logic_vector(31 downto 0) := (others => '0');
   begin
      result(31 downto 26) := opcode;
      result(25 downto 21) := std_logic_vector(to_unsigned(rD,5));
      result(20 downto 16) := std_logic_vector(to_unsigned(rA,5));
      result(15 downto 11) := std_logic_vector(to_unsigned(rB,5));
      result(10)           := S;
      result(9)            := T;
      
      return result;
   end function; 

   function instr_B_bsl(rD,rA,imm : integer; opcode : std_logic_vector(5 downto 0);S,T : std_logic) return std_logic_vector is
   variable result : std_logic_vector(31 downto 0) := (others => '0');
   begin
      result(31 downto 26) := opcode;
      result(25 downto 21) := std_logic_vector(to_unsigned(rD,5));
      result(20 downto 16) := std_logic_vector(to_unsigned(rA,5));
      result(10)           := S;
      result(9)            := T;      
      result(4 downto  0)  := std_logic_vector(to_unsigned(imm,5));      
      return result;
   end function;   
      
   

end;
