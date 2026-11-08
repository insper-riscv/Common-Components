-- =============================================================================
-- Multiplexador 16x1 parametrizável
--
-- Seleciona combinacionalmente entre 16 barramentos de entrada de largura
-- configurável (data_width) de acordo com o seletor i_sel de 4 bits: com k o
-- valor numérico de i_sel, o_d recebe i_dk. A seleção é feita pelo mux_tree.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity mux_16x1 is
	generic (
		-- Largura dos barramentos de dados (em bits).
		data_width : natural := 8
	);
	port (
		-- Entrada de dados 0 (selecionada quando i_sel vale 0).
		i_d0 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 1 (selecionada quando i_sel vale 1).
		i_d1 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 2 (selecionada quando i_sel vale 2).
		i_d2 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 3 (selecionada quando i_sel vale 3).
		i_d3 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 4 (selecionada quando i_sel vale 4).
		i_d4 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 5 (selecionada quando i_sel vale 5).
		i_d5 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 6 (selecionada quando i_sel vale 6).
		i_d6 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 7 (selecionada quando i_sel vale 7).
		i_d7 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 8 (selecionada quando i_sel vale 8).
		i_d8 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 9 (selecionada quando i_sel vale 9).
		i_d9 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 10 (selecionada quando i_sel vale 10).
		i_d10 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 11 (selecionada quando i_sel vale 11).
		i_d11 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 12 (selecionada quando i_sel vale 12).
		i_d12 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 13 (selecionada quando i_sel vale 13).
		i_d13 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 14 (selecionada quando i_sel vale 14).
		i_d14 : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 15 (selecionada quando i_sel vale 15).
		i_d15 : in  std_logic_vector((data_width - 1) downto 0);
		-- Seletor da entrada que chega à saída.
		i_sel : in  std_logic_vector(3 downto 0);
		-- Saída de dados selecionada.
		o_d   : out std_logic_vector((data_width - 1) downto 0)
	);
end entity mux_16x1;

architecture rtl of mux_16x1 is

	-- Matriz com as 16 entradas, na ordem do índice de seleção.
	signal s_array : word_array_t(15 downto 0)((data_width - 1) downto 0);

begin

	s_array(0) <= i_d0;
	s_array(1) <= i_d1;
	s_array(2) <= i_d2;
	s_array(3) <= i_d3;
	s_array(4) <= i_d4;
	s_array(5) <= i_d5;
	s_array(6) <= i_d6;
	s_array(7) <= i_d7;
	s_array(8) <= i_d8;
	s_array(9) <= i_d9;
	s_array(10) <= i_d10;
	s_array(11) <= i_d11;
	s_array(12) <= i_d12;
	s_array(13) <= i_d13;
	s_array(14) <= i_d14;
	s_array(15) <= i_d15;

	u_tree : entity work.mux_tree
		generic map (
			data_width     => data_width,
			selector_width => 4
		)
		port map (
			i_array => s_array,
			i_sel   => i_sel,
			o_d     => o_d
		);

end architecture rtl;
