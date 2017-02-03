-- **********************************************************************************
--   Project          : MiniBlaze
--   Author           : Benjamin Lemoine
--   Module           : tb_sequencer
--   Date             : 08/05/2016
--
--   Description      : Test bench for Sequencer unit
--
--   --------------------------------------------------------------------------------
--   Modifications
--   --------------------------------------------------------------------------------
--   Date             : Ver. : Author           : Modification comments
--   --------------------------------------------------------------------------------
--                    :      :                  :
--   08/05/2016      : 1.0  : B.Lemoine        : First draft
--                    :      :                  :
-- **********************************************************************************
--   MIT License
--   
--   Copyright (c) 08/05/2016, Benjamin Lemoine
--   
--   Permission is hereby granted, free of charge, to any person obtaining a copy
--   of this software and associated documentation files (the "Software"), to deal
--   in the Software without restriction, including without limitation the rights
--   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--   copies of the Software, and to permit persons to whom the Software is
--   furnished to do so, subject to the following conditions:
--   
--   The above copyright notice and this permission notice shall be included in all
--   copies or substantial portions of the Software.
--   
--   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--   SOFTWARE.
-- **********************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.tb_sequencer_pkg.all;

entity tb_sequencer is  
end entity;


architecture rtl of tb_sequencer is

-- Components declaration
Component sequencer is
   generic(
      D_WIDTH  : natural := 32
   );
   port(
      -- Clock and reset
      clk               : in  std_logic;
      reset_n           : in  std_logic;
      -- Interface memory in
      data_mem_in_i     : in  std_logic_vector(D_WIDTH-1 downto 0);
      data_mem_in_en_i  : in  std_logic;
      addr_mem_in_o     : out std_logic_vector(D_WIDTH-1 downto 0);
      rd_en_mem_in_o    : out std_logic;
      -- Interface memory out
      addr_mem_out_o    : out std_logic_vector(D_WIDTH-1 downto 0);
      data_mem_out_o    : out std_logic_vector(D_WIDTH-1 downto 0);
      wr_en_mem_out_o   : out std_logic_vector(3 downto 0)
   );
end Component;

Component bytewrite_ram is
   generic (
      ADDR_WIDTH : integer := 15;
      COL_WIDTH  : integer := 16;
      NB_COL     : integer := 4
   );
   port (
      clk  : in  std_logic;
      we   : in  std_logic_vector(NB_COL-1 downto 0);
      addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      di   : in  std_logic_vector(NB_COL*COL_WIDTH-1 downto 0);
      do   : out std_logic_vector(NB_COL*COL_WIDTH-1 downto 0)
   );
end Component;

-- Constant declaration
constant SIZE_MEM       : integer   := 5;

-- Signals declaration
signal data_o           : std_logic_vector(31 downto 0);
signal data_i           : std_logic_vector(31 downto 0);
signal s_data_i         : std_logic_vector(31 downto 0);
signal addr_in          : std_logic_vector(31 downto 0);
signal addr_out         : std_logic_vector(31 downto 0);
signal addr             : std_logic_vector(SIZE_MEM-1 downto 0);  
signal s_addr           : std_logic_vector(SIZE_MEM-1 downto 0);  
signal wr_en            : std_logic_vector(3 downto 0);
signal s_wr_en          : std_logic_vector(3 downto 0);

signal clk              : std_logic := '0';
signal reset_n          : std_logic := '0';

signal r_init_done      : std_logic := '0';
signal r_cnt            : unsigned(31 downto 0) := (others => '0');
signal addr_init        : std_logic_vector(31 downto 0);
signal data_init        : std_logic_vector(31 downto 0);
signal wr_en_init        : std_logic_vector(3 downto 0);

signal data_o_en : std_logic;
signal r_data_o_en : std_logic;
signal rd_en : std_logic;

constant c_size_init    : integer  := 10;
type tab_mem is array (0 to c_size_init-1) of std_logic_vector(31 downto 0);
constant t_init         :  tab_mem := (
instr_B( 4, 0, 16, "001000"), -- addi r4 r0 16 (16+0 dans r4)
instr_B( 5, 4,  4, "001000"), -- addi r5 r4 4 (16+4 dans r5)
instr_B( 6, 5,  2, "011000"), -- mul r6 r5 2 (20*2 dans r6)
instr_B( 4, 5, 20, "111110"), -- str r4 r5 20 (*(20+20) = 16)
instr_B( 3, 0, 36, "111001"), -- load addr 9 into r3
instr_B( 0, 1,  1, "001000"), -- addi r0 r1 1 (1+0 dans r0)
instr_B( 0, 8,  0, "101110"), -- branch to start
(others => '0'),
(others => '0'),
x"12345678"
);

   


begin

   -- Clock generation (125 MHz)
   clk   <= not clk after 4 ns; 
   
   -- Reset at the start of the simulation for 100 ns
   process
   begin
      reset_n  <= '0';
      wait until r_init_done = '1';
      reset_n  <= '1';
      wait;
   end process;


   i_sequencer : sequencer 
      generic map (
         D_WIDTH           => 32
      )
      port map(
         -- Clock and reset
         clk               => clk,
         reset_n           => reset_n,
         -- Interface memory in
         data_mem_in_i     => data_o,
         data_mem_in_en_i  => r_data_o_en,
         addr_mem_in_o     => addr_in,
         rd_en_mem_in_o    => rd_en,
         -- Interface memory out
         addr_mem_out_o    => addr_out,
         data_mem_out_o    => s_data_i,
         wr_en_mem_out_o   => s_wr_en
      );
      
   s_addr <= addr_in(SIZE_MEM+1 downto 2) when s_wr_en = x"0" else addr_out(SIZE_MEM+1 downto 2);
   
   i_bytewrite_ram : bytewrite_ram 
   generic map (
      ADDR_WIDTH     => SIZE_MEM,
      COL_WIDTH      => 8,
      NB_COL         => 4
   )
   port map(
      clk            => clk,
      we             => wr_en,
      addr           => addr,
      di             => data_i,
      do             => data_o
   );  
   
   -- Init memory
   process(clk)
   begin
      if rising_edge(clk) then
         r_data_o_en <= rd_en;
      
         if r_cnt < c_size_init then
            r_init_done    <= '0';
            r_cnt          <= r_cnt + 1;
            addr_init      <= std_logic_vector(r_cnt);
            data_init      <= t_init(to_integer(r_cnt));
            wr_en_init     <= (others => '1');
         else
            r_init_done    <= '1';
            wr_en_init     <= (others => '0');
         end if;
      end if;
   end process;
   
   addr        <= addr_init(SIZE_MEM-1 downto 0) when r_init_done = '0' else s_addr;
   data_i      <= data_init when r_init_done = '0' else s_data_i;
   wr_en       <= wr_en_init when r_init_done = '0' else s_wr_en;
            
   

end rtl;
   
      