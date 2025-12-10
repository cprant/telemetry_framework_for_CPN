-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Fri Dec 16 17:10:08 2022
-- Host        : DESKTOP-CQ69JDQ running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top bd_1953_c_shift_ram_0_0 -prefix
--               bd_1953_c_shift_ram_0_0_ bd_1953_c_shift_ram_0_0_sim_netlist.vhdl
-- Design      : bd_1953_c_shift_ram_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7k325tffg676-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_1953_c_shift_ram_0_0_c_reg_fd_v12_0_5_viv is
  port (
    q : out STD_LOGIC_VECTOR ( 0 to 0 );
    clk : in STD_LOGIC;
    ce : in STD_LOGIC;
    d : in STD_LOGIC_VECTOR ( 0 to 0 );
    sclr : in STD_LOGIC
  );
end bd_1953_c_shift_ram_0_0_c_reg_fd_v12_0_5_viv;

architecture STRUCTURE of bd_1953_c_shift_ram_0_0_c_reg_fd_v12_0_5_viv is
  signal \i_no_async_controls.output[1]_i_1_n_0\ : STD_LOGIC;
  signal \^q\ : STD_LOGIC_VECTOR ( 0 to 0 );
begin
  q(0) <= \^q\(0);
\i_no_async_controls.output[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => \^q\(0),
      I1 => ce,
      I2 => d(0),
      I3 => sclr,
      O => \i_no_async_controls.output[1]_i_1_n_0\
    );
\i_no_async_controls.output_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => '1',
      D => \i_no_async_controls.output[1]_i_1_n_0\,
      Q => \^q\(0),
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy is
  port (
    a : in STD_LOGIC_VECTOR ( 3 downto 0 );
    d : in STD_LOGIC_VECTOR ( 0 to 0 );
    clk : in STD_LOGIC;
    ce : in STD_LOGIC;
    aclr : in STD_LOGIC;
    aset : in STD_LOGIC;
    ainit : in STD_LOGIC;
    sclr : in STD_LOGIC;
    sset : in STD_LOGIC;
    sinit : in STD_LOGIC;
    q : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute C_ADDR_WIDTH : integer;
  attribute C_ADDR_WIDTH of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 4;
  attribute C_AINIT_VAL : string;
  attribute C_AINIT_VAL of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "0";
  attribute C_DEFAULT_DATA : string;
  attribute C_DEFAULT_DATA of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "0";
  attribute C_DEPTH : integer;
  attribute C_DEPTH of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 1;
  attribute C_ELABORATION_DIR : string;
  attribute C_ELABORATION_DIR of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "./";
  attribute C_HAS_A : integer;
  attribute C_HAS_A of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_HAS_CE : integer;
  attribute C_HAS_CE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 1;
  attribute C_HAS_SCLR : integer;
  attribute C_HAS_SCLR of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 1;
  attribute C_HAS_SINIT : integer;
  attribute C_HAS_SINIT of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_HAS_SSET : integer;
  attribute C_HAS_SSET of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_MEM_INIT_FILE : string;
  attribute C_MEM_INIT_FILE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "no_coe_file_loaded";
  attribute C_OPT_GOAL : integer;
  attribute C_OPT_GOAL of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_PARSER_TYPE : integer;
  attribute C_PARSER_TYPE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_READ_MIF : integer;
  attribute C_READ_MIF of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_REG_LAST_BIT : integer;
  attribute C_REG_LAST_BIT of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 1;
  attribute C_SHIFT_TYPE : integer;
  attribute C_SHIFT_TYPE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_SINIT_VAL : string;
  attribute C_SINIT_VAL of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "0";
  attribute C_SYNC_ENABLE : integer;
  attribute C_SYNC_ENABLE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_SYNC_PRIORITY : integer;
  attribute C_SYNC_PRIORITY of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 1;
  attribute C_VERBOSITY : integer;
  attribute C_VERBOSITY of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute C_WIDTH : integer;
  attribute C_WIDTH of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 1;
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "kintex7";
  attribute c_default_data_radix : integer;
  attribute c_default_data_radix of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 1;
  attribute c_enable_rlocs : integer;
  attribute c_enable_rlocs of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute c_generate_mif : integer;
  attribute c_generate_mif of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute c_has_aclr : integer;
  attribute c_has_aclr of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute c_has_ainit : integer;
  attribute c_has_ainit of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute c_has_aset : integer;
  attribute c_has_aset of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 0;
  attribute c_mem_init_radix : integer;
  attribute c_mem_init_radix of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is 1;
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "yes";
  attribute opt_mode : string;
  attribute opt_mode of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "AREA";
  attribute optimize_primitives : string;
  attribute optimize_primitives of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "NO";
  attribute shreg_extract : string;
  attribute shreg_extract of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "yes";
  attribute use_clock_enable : string;
  attribute use_clock_enable of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy : entity is "YES";
end bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy;

architecture STRUCTURE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy is
begin
\gen_output_regs.output_regs\: entity work.bd_1953_c_shift_ram_0_0_c_reg_fd_v12_0_5_viv
     port map (
      ce => ce,
      clk => clk,
      d(0) => d(0),
      q(0) => q(0),
      sclr => sclr
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_viv is
  port (
    Q : out STD_LOGIC_VECTOR ( 0 to 0 );
    D : in STD_LOGIC_VECTOR ( 0 to 0 );
    CLK : in STD_LOGIC;
    CE : in STD_LOGIC;
    SCLR : in STD_LOGIC
  );
end bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_viv;

architecture STRUCTURE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_viv is
  attribute C_AINIT_VAL : string;
  attribute C_AINIT_VAL of i_bb_inst : label is "0";
  attribute C_ENABLE_RLOCS : integer;
  attribute C_ENABLE_RLOCS of i_bb_inst : label is 0;
  attribute C_HAS_ACLR : integer;
  attribute C_HAS_ACLR of i_bb_inst : label is 0;
  attribute C_HAS_AINIT : integer;
  attribute C_HAS_AINIT of i_bb_inst : label is 0;
  attribute C_HAS_ASET : integer;
  attribute C_HAS_ASET of i_bb_inst : label is 0;
  attribute C_HAS_CE : integer;
  attribute C_HAS_CE of i_bb_inst : label is 1;
  attribute C_HAS_SCLR : integer;
  attribute C_HAS_SCLR of i_bb_inst : label is 1;
  attribute C_HAS_SINIT : integer;
  attribute C_HAS_SINIT of i_bb_inst : label is 0;
  attribute C_HAS_SSET : integer;
  attribute C_HAS_SSET of i_bb_inst : label is 0;
  attribute C_SINIT_VAL : string;
  attribute C_SINIT_VAL of i_bb_inst : label is "0";
  attribute C_SYNC_ENABLE : integer;
  attribute C_SYNC_ENABLE of i_bb_inst : label is 0;
  attribute C_SYNC_PRIORITY : integer;
  attribute C_SYNC_PRIORITY of i_bb_inst : label is 1;
  attribute C_WIDTH : integer;
  attribute C_WIDTH of i_bb_inst : label is 1;
  attribute SHREG_EXTRACT : string;
  attribute SHREG_EXTRACT of i_bb_inst : label is "yes";
  attribute c_addr_width : integer;
  attribute c_addr_width of i_bb_inst : label is 4;
  attribute c_default_data : string;
  attribute c_default_data of i_bb_inst : label is "0";
  attribute c_default_data_radix : integer;
  attribute c_default_data_radix of i_bb_inst : label is 1;
  attribute c_depth : integer;
  attribute c_depth of i_bb_inst : label is 1;
  attribute c_elaboration_dir : string;
  attribute c_elaboration_dir of i_bb_inst : label is "./";
  attribute c_generate_mif : integer;
  attribute c_generate_mif of i_bb_inst : label is 0;
  attribute c_has_a : integer;
  attribute c_has_a of i_bb_inst : label is 0;
  attribute c_mem_init_file : string;
  attribute c_mem_init_file of i_bb_inst : label is "no_coe_file_loaded";
  attribute c_mem_init_radix : integer;
  attribute c_mem_init_radix of i_bb_inst : label is 1;
  attribute c_opt_goal : integer;
  attribute c_opt_goal of i_bb_inst : label is 0;
  attribute c_parser_type : integer;
  attribute c_parser_type of i_bb_inst : label is 0;
  attribute c_read_mif : integer;
  attribute c_read_mif of i_bb_inst : label is 0;
  attribute c_reg_last_bit : integer;
  attribute c_reg_last_bit of i_bb_inst : label is 1;
  attribute c_shift_type : integer;
  attribute c_shift_type of i_bb_inst : label is 0;
  attribute c_verbosity : integer;
  attribute c_verbosity of i_bb_inst : label is 0;
  attribute c_xdevicefamily : string;
  attribute c_xdevicefamily of i_bb_inst : label is "kintex7";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of i_bb_inst : label is "yes";
  attribute opt_mode : string;
  attribute opt_mode of i_bb_inst : label is "AREA";
  attribute optimize_primitives : string;
  attribute optimize_primitives of i_bb_inst : label is "NO";
  attribute use_clock_enable : string;
  attribute use_clock_enable of i_bb_inst : label is "YES";
begin
i_bb_inst: entity work.bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy
     port map (
      a(3 downto 0) => B"0000",
      aclr => '0',
      ainit => '0',
      aset => '0',
      ce => CE,
      clk => CLK,
      d(0) => D(0),
      q(0) => Q(0),
      sclr => SCLR,
      sinit => '0',
      sset => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 is
  port (
    A : in STD_LOGIC_VECTOR ( 3 downto 0 );
    D : in STD_LOGIC_VECTOR ( 0 to 0 );
    CLK : in STD_LOGIC;
    CE : in STD_LOGIC;
    SCLR : in STD_LOGIC;
    SSET : in STD_LOGIC;
    SINIT : in STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute C_ADDR_WIDTH : integer;
  attribute C_ADDR_WIDTH of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 4;
  attribute C_AINIT_VAL : string;
  attribute C_AINIT_VAL of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is "0";
  attribute C_DEFAULT_DATA : string;
  attribute C_DEFAULT_DATA of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is "0";
  attribute C_DEPTH : integer;
  attribute C_DEPTH of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 1;
  attribute C_ELABORATION_DIR : string;
  attribute C_ELABORATION_DIR of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is "./";
  attribute C_HAS_A : integer;
  attribute C_HAS_A of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_HAS_CE : integer;
  attribute C_HAS_CE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 1;
  attribute C_HAS_SCLR : integer;
  attribute C_HAS_SCLR of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 1;
  attribute C_HAS_SINIT : integer;
  attribute C_HAS_SINIT of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_HAS_SSET : integer;
  attribute C_HAS_SSET of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_MEM_INIT_FILE : string;
  attribute C_MEM_INIT_FILE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is "no_coe_file_loaded";
  attribute C_OPT_GOAL : integer;
  attribute C_OPT_GOAL of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_PARSER_TYPE : integer;
  attribute C_PARSER_TYPE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_READ_MIF : integer;
  attribute C_READ_MIF of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_REG_LAST_BIT : integer;
  attribute C_REG_LAST_BIT of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 1;
  attribute C_SHIFT_TYPE : integer;
  attribute C_SHIFT_TYPE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_SINIT_VAL : string;
  attribute C_SINIT_VAL of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is "0";
  attribute C_SYNC_ENABLE : integer;
  attribute C_SYNC_ENABLE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_SYNC_PRIORITY : integer;
  attribute C_SYNC_PRIORITY of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 1;
  attribute C_VERBOSITY : integer;
  attribute C_VERBOSITY of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 0;
  attribute C_WIDTH : integer;
  attribute C_WIDTH of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is 1;
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is "kintex7";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 : entity is "yes";
end bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12;

architecture STRUCTURE of bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 is
begin
i_synth: entity work.bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_viv
     port map (
      CE => CE,
      CLK => CLK,
      D(0) => D(0),
      Q(0) => Q(0),
      SCLR => SCLR
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_1953_c_shift_ram_0_0 is
  port (
    D : in STD_LOGIC_VECTOR ( 0 to 0 );
    CLK : in STD_LOGIC;
    CE : in STD_LOGIC;
    SCLR : in STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of bd_1953_c_shift_ram_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of bd_1953_c_shift_ram_0_0 : entity is "bd_1953_c_shift_ram_0_0,c_shift_ram_v12_0_12,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of bd_1953_c_shift_ram_0_0 : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of bd_1953_c_shift_ram_0_0 : entity is "c_shift_ram_v12_0_12,Vivado 2018.3";
end bd_1953_c_shift_ram_0_0;

architecture STRUCTURE of bd_1953_c_shift_ram_0_0 is
  attribute C_AINIT_VAL : string;
  attribute C_AINIT_VAL of U0 : label is "0";
  attribute C_HAS_CE : integer;
  attribute C_HAS_CE of U0 : label is 1;
  attribute C_HAS_SCLR : integer;
  attribute C_HAS_SCLR of U0 : label is 1;
  attribute C_HAS_SINIT : integer;
  attribute C_HAS_SINIT of U0 : label is 0;
  attribute C_HAS_SSET : integer;
  attribute C_HAS_SSET of U0 : label is 0;
  attribute C_SINIT_VAL : string;
  attribute C_SINIT_VAL of U0 : label is "0";
  attribute C_SYNC_ENABLE : integer;
  attribute C_SYNC_ENABLE of U0 : label is 0;
  attribute C_SYNC_PRIORITY : integer;
  attribute C_SYNC_PRIORITY of U0 : label is 1;
  attribute C_WIDTH : integer;
  attribute C_WIDTH of U0 : label is 1;
  attribute c_addr_width : integer;
  attribute c_addr_width of U0 : label is 4;
  attribute c_default_data : string;
  attribute c_default_data of U0 : label is "0";
  attribute c_depth : integer;
  attribute c_depth of U0 : label is 1;
  attribute c_elaboration_dir : string;
  attribute c_elaboration_dir of U0 : label is "./";
  attribute c_has_a : integer;
  attribute c_has_a of U0 : label is 0;
  attribute c_mem_init_file : string;
  attribute c_mem_init_file of U0 : label is "no_coe_file_loaded";
  attribute c_opt_goal : integer;
  attribute c_opt_goal of U0 : label is 0;
  attribute c_parser_type : integer;
  attribute c_parser_type of U0 : label is 0;
  attribute c_read_mif : integer;
  attribute c_read_mif of U0 : label is 0;
  attribute c_reg_last_bit : integer;
  attribute c_reg_last_bit of U0 : label is 1;
  attribute c_shift_type : integer;
  attribute c_shift_type of U0 : label is 0;
  attribute c_verbosity : integer;
  attribute c_verbosity of U0 : label is 0;
  attribute c_xdevicefamily : string;
  attribute c_xdevicefamily of U0 : label is "kintex7";
  attribute downgradeipidentifiedwarnings of U0 : label is "yes";
  attribute x_interface_info : string;
  attribute x_interface_info of CE : signal is "xilinx.com:signal:clockenable:1.0 ce_intf CE";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of CE : signal is "XIL_INTERFACENAME ce_intf, POLARITY ACTIVE_LOW";
  attribute x_interface_info of CLK : signal is "xilinx.com:signal:clock:1.0 clk_intf CLK";
  attribute x_interface_parameter of CLK : signal is "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:d_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0";
  attribute x_interface_info of SCLR : signal is "xilinx.com:signal:reset:1.0 sclr_intf RST";
  attribute x_interface_parameter of SCLR : signal is "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0";
  attribute x_interface_info of D : signal is "xilinx.com:signal:data:1.0 d_intf DATA";
  attribute x_interface_parameter of D : signal is "XIL_INTERFACENAME d_intf, LAYERED_METADATA undef";
  attribute x_interface_info of Q : signal is "xilinx.com:signal:data:1.0 q_intf DATA";
  attribute x_interface_parameter of Q : signal is "XIL_INTERFACENAME q_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency data_bitwidth format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} DATA_WIDTH 1}";
begin
U0: entity work.bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12
     port map (
      A(3 downto 0) => B"0000",
      CE => CE,
      CLK => CLK,
      D(0) => D(0),
      Q(0) => Q(0),
      SCLR => SCLR,
      SINIT => '0',
      SSET => '0'
    );
end STRUCTURE;
