-- =============================================================================
-- Multiplexador em árvore parametrizável
--
-- Seleciona uma palavra de largura data_width a partir de uma matriz de
-- 2^selector_width palavras (i_array) por meio de uma árvore balanceada de
-- estágios de seleção controlados por i_sel. Cada estágio consome stage_bits
-- bits do seletor (do menos significativo ao mais significativo) e escolhe
-- entre 2^stage_bits palavras adjacentes do estágio anterior. Com stage_bits
-- igual a 1 a árvore é binária (estágios 2x1); com 2, de estágios 4x1; com 3,
-- de estágios 8x1. Quando selector_width não é múltiplo de stage_bits, o último
-- estágio consome os bits restantes (por exemplo, 5 bits com stage_bits igual a
-- 2 resultam em estágios de 2, 2 e 1 bit). O bloco não conhece o dispositivo de
-- destino: stage_bits só escolhe a estrutura, e o resultado funcional é o mesmo
-- para qualquer valor.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity mux_tree is
	generic (
		-- Largura de cada palavra de dados (em bits).
		data_width     : natural  := 8;
		-- Largura do seletor binário (2^selector_width palavras de entrada).
		selector_width : natural  := 5;
		-- Bits do seletor consumidos por estágio (1 = estágios 2x1, 2 = 4x1, 3 = 8x1). Um valor acima de
		-- selector_width resulta em um único estágio. Zero é recusado na elaboração (subtipo positive).
		stage_bits     : positive := 1
	);
	port (
		-- Matriz de palavras de entrada.
		i_array : in    word_array_t(((2 ** selector_width) - 1) downto 0)((data_width - 1) downto 0);
		-- Índice binário da palavra selecionada.
		i_sel   : in    std_logic_vector((selector_width - 1) downto 0);
		-- Palavra selecionada na saída da árvore de multiplexadores.
		o_d     : out   std_logic_vector((data_width - 1) downto 0)
	);
end entity mux_tree;

architecture rtl of mux_tree is

	-- Quantidade de estágios da árvore: selector_width dividido por stage_bits, arredondado para cima.
	constant STAGE_COUNT : natural := (selector_width + stage_bits - 1) / stage_bits;

	-- Retorna quantos bits do seletor já foram consumidos pelos estágios anteriores ao estágio s, sem passar
	-- de selector_width.

	function consumed_bits (s : natural) return natural is
	begin

		return minimum(s * stage_bits, selector_width);

	end function consumed_bits;

	-- Tipo de array para os estagios intermediarios da arvore de muxes
	type mux_tree_t is array (STAGE_COUNT downto 0) of
		word_array_t(((2 ** selector_width) - 1) downto 0)((data_width - 1) downto 0);

	-- Sinais para cada estagio da arvore de muxes
	signal mux_levels : mux_tree_t;

begin

	mux_levels(0) <= i_array;

	-- Gera os estagios da arvore de muxes

	gen_mux_tree : for s in 0 to (STAGE_COUNT - 1) generate

		-- Bit menos significativo do seletor usado neste estágio.
		constant SEL_LOW  : natural := consumed_bits(s);
		-- Bit mais significativo do seletor usado neste estágio.
		constant SEL_HIGH : natural := consumed_bits(s + 1) - 1;
		-- Quantidade de palavras do estágio s+1, depois de consumir os bits deste estágio.
		constant WORDS    : natural := 2 ** (selector_width - consumed_bits(s + 1));
		-- Quantidade de palavras do estágio s que cada multiplexador deste estágio escolhe.
		constant FAN_IN   : natural := 2 ** (SEL_HIGH - SEL_LOW + 1);

		-- Índice, dentro do grupo de FAN_IN palavras, da palavra escolhida neste estágio.
		signal stage_sel : natural range 0 to (FAN_IN - 1);

	begin

		stage_sel <= to_integer(unsigned(i_sel(SEL_HIGH downto SEL_LOW)));

		-- Cada multiplexador do estágio seleciona entre FAN_IN palavras adjacentes do estágio anterior; a
		-- palavra j do estágio seguinte nasce do grupo que começa em j * FAN_IN.

		gen_muxes : for j in 0 to (WORDS - 1) generate

			mux_levels(s + 1)(j) <= mux_levels(s)(j * FAN_IN + stage_sel);

		end generate gen_muxes;

		-- As palavras do estágio 's+1' além dos multiplexadores acima não alimentam nada; recebem zero para que
		-- nenhum bit do sinal fique sem driver (a síntese as remove).

		gen_unused : for j in WORDS to ((2 ** selector_width) - 1) generate

			mux_levels(s + 1)(j) <= (others => '0');

		end generate gen_unused;

	end generate gen_mux_tree;

	-- A saida e o resultado do ultimo estagio
	o_d <= mux_levels(STAGE_COUNT)(0);

end architecture rtl;
