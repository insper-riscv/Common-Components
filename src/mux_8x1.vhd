-- =============================================================================
-- Multiplexador 8x1 parametrizável
--
-- Seleciona combinacionalmente entre oito barramentos de entrada de largura
-- configurável (data_width) de acordo com o seletor i_sel de 3 bits:
--   - i_sel = "000" -> o_d recebe i_d0
--   - i_sel = "001" -> o_d recebe i_d1
--   - i_sel = "010" -> o_d recebe i_d2
--   - i_sel = "011" -> o_d recebe i_d3
--   - i_sel = "100" -> o_d recebe i_d4
--   - i_sel = "101" -> o_d recebe i_d5
--   - i_sel = "110" -> o_d recebe i_d6
--   - i_sel = "111" -> o_d recebe i_d7
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity mux_8x1 is
	generic (
		-- Largura dos barramentos de dados (em bits).
		data_width : natural := 8
	);
	port (
		-- Entrada de dados 0 (selecionada quando i_sel = "000").
		i_d0  : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 1 (selecionada quando i_sel = "001").
		i_d1  : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 2 (selecionada quando i_sel = "010").
		i_d2  : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 3 (selecionada quando i_sel = "011").
		i_d3  : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 4 (selecionada quando i_sel = "100").
		i_d4  : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 5 (selecionada quando i_sel = "101").
		i_d5  : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 6 (selecionada quando i_sel = "110").
		i_d6  : in  std_logic_vector((data_width - 1) downto 0);
		-- Entrada de dados 7 (selecionada quando i_sel = "111").
		i_d7  : in  std_logic_vector((data_width - 1) downto 0);
		-- Seletor da entrada que chega à saída.
		i_sel : in  std_logic_vector(2 downto 0);
		-- Saída de dados selecionada.
		o_d   : out std_logic_vector((data_width - 1) downto 0)
	);
end entity mux_8x1;

architecture rtl of mux_8x1 is
begin

	with i_sel select
		o_d <= i_d0 when "000",
		       i_d1 when "001",
		       i_d2 when "010",
		       i_d3 when "011",
		       i_d4 when "100",
		       i_d5 when "101",
		       i_d6 when "110",
		       i_d7 when others;

end architecture rtl;
