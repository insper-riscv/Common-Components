-- =============================================================================
-- Invólucro de teste do mux_tree
--
-- Achata o vetor de palavras de entrada do mux_tree (um tipo não restrito que o
-- cocotb não enxerga) em um único vetor de std_logic: a palavra i ocupa os bits
-- [4*i+3 : 4*i] de i_flat.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity mux_tree_tb is
	port (
		-- As oito palavras de 4 bits, uma depois da outra (a palavra 0 nos bits menos significativos).
		i_flat : in  std_logic_vector(31 downto 0);
		-- Índice da palavra selecionada.
		i_sel  : in  std_logic_vector(2 downto 0);
		-- Palavra selecionada.
		o_d    : out std_logic_vector(3 downto 0)
	);
end entity mux_tree_tb;

architecture rtl of mux_tree_tb is

	-- As oito palavras de entrada, reunidas no tipo que o mux_tree espera.
	signal words : word_array_t(7 downto 0)(3 downto 0);

begin

	gen_words : for i in 0 to 7 generate
		words(i) <= i_flat((4 * i + 3) downto (4 * i));
	end generate gen_words;

	u_mux_tree : entity work.mux_tree
		generic map (
			data_width     => 4,
			selector_width => 3
		)
		port map (
			i_array => words,
			i_sel   => i_sel,
			o_d     => o_d
		);

end architecture rtl;
