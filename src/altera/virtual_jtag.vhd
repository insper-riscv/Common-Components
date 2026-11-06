-- =============================================================================
-- Virtual JTAG da Intel (sld_virtual_jtag) com índice de instância e largura de
-- IR por generic
--
-- Única instância do megafunction sld_virtual_jtag do projeto: os invólucros de
-- FLASH, JTAG UART, display e SDRAM instanciam esta entidade em vez de repetir o
-- generic map e o mapa de portas da Intel. Exclusiva da FPGA (precisa da
-- biblioteca altera_mf), então não é analisada pelo GHDL da imagem de
-- ferramentas; nas simulações o testbench faz o papel desta entidade e dirige o
-- núcleo atrás dela direto.
--
-- O hospedeiro enxerga uma instância de IR com ir_width bits no índice
-- instance_index. Os estados Exit1-DR, Pause-DR, Exit2-DR e Capture-IR da
-- cadeia virtual não são usados por nenhum núcleo e ficam sem saída. O
-- registrador ir_out do megafunction é mantido em zero.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity virtual_jtag is
	generic (
		-- Índice da instância que o hospedeiro usa para alcançá-la.
		instance_index      : natural  := 0;
		-- "YES" deixa o Quartus escolher o índice livre mais baixo; "NO" fixa o índice em instance_index.
		auto_instance_index : string   := "NO";
		-- Largura do registrador de instrução virtual, em bits.
		ir_width            : positive := 2
	);
	port (
		-- Clock da cadeia JTAG.
		o_tck       : out std_logic;
		-- Dado serial vindo do hospedeiro.
		o_tdi       : out std_logic;
		-- Dado serial para o hospedeiro.
		i_tdo       : in  std_logic;
		-- Registrador de instrução virtual.
		o_ir_in     : out std_logic_vector (ir_width - 1 downto 0);
		-- Estado Capture-DR da cadeia virtual.
		o_state_cdr : out std_logic;
		-- Estado Shift-DR da cadeia virtual.
		o_state_sdr : out std_logic;
		-- Estado Update-DR da cadeia virtual.
		o_state_udr : out std_logic;
		-- Estado Update-IR da cadeia virtual.
		o_state_uir : out std_logic
	);
end entity virtual_jtag;

architecture rtl of virtual_jtag is

	-- Estado Exit1-DR, não usado.
	signal unused_e1dr : std_logic;
	-- Estado Pause-DR, não usado.
	signal unused_pdr  : std_logic;
	-- Estado Exit2-DR, não usado.
	signal unused_e2dr : std_logic;
	-- Estado Capture-IR, não usado.
	signal unused_cir  : std_logic;

begin

	u_vjtag : sld_virtual_jtag
	generic map (
		lpm_type => "sld_virtual_jtag",
		lpm_hint => "sld_instance_index=" & integer'image(instance_index),
		sld_auto_instance_index => auto_instance_index,
		sld_instance_index => instance_index,
		sld_ir_width => ir_width,
		sld_sim_n_scan => 0,
		sld_sim_total_length => 0,
		sld_sim_action => ""
	)
	port map (
		tdo => i_tdo, ir_out => (others => '0'),
		tck => o_tck, tdi => o_tdi, ir_in => o_ir_in,
		virtual_state_cdr => o_state_cdr, virtual_state_sdr => o_state_sdr,
		virtual_state_e1dr => unused_e1dr, virtual_state_pdr => unused_pdr,
		virtual_state_e2dr => unused_e2dr, virtual_state_udr => o_state_udr,
		virtual_state_cir => unused_cir, virtual_state_uir => o_state_uir
	);

end architecture rtl;
