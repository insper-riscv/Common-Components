-- =============================================================================
-- Invólucro de teste do mux_tree
--
-- Achata o vetor de palavras de entrada do mux_tree (um tipo não restrito que o
-- cocotb não enxerga) em um único vetor de std_logic: a palavra i ocupa os bits
-- [data_width*i+data_width-1 : data_width*i] de i_flat. Os genéricos repassam a
-- largura da palavra, a largura do seletor e os bits por estágio ao mux_tree.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity mux_tree_tb is
    generic (
        -- Largura de cada palavra de dados (em bits).
        data_width     : natural  := 4;
        -- Largura do seletor binário (2^selector_width palavras de entrada).
        selector_width : natural  := 3;
        -- Bits do seletor consumidos por estágio do mux_tree.
        stage_bits     : positive := 1
    );
    port (
        -- As palavras de entrada, uma depois da outra (a palavra 0 nos bits menos significativos).
        i_flat : in    std_logic_vector(((data_width * (2 ** selector_width)) - 1) downto 0);
        -- Índice da palavra selecionada.
        i_sel  : in    std_logic_vector((selector_width - 1) downto 0);
        -- Palavra selecionada.
        o_d    : out   std_logic_vector((data_width - 1) downto 0)
    );
end entity mux_tree_tb;

architecture rtl of mux_tree_tb is

    -- As palavras de entrada, reunidas no tipo que o mux_tree espera.
    signal words : word_array_t(((2 ** selector_width) - 1) downto 0)((data_width - 1) downto 0);

begin

    gen_words : for i in 0 to ((2 ** selector_width) - 1) generate
        words(i) <= i_flat(((data_width * i) + data_width - 1) downto (data_width * i));
    end generate gen_words;

    u_mux_tree : entity work.mux_tree
        generic map (
            data_width     => data_width,
            selector_width => selector_width,
            stage_bits     => stage_bits
        )
        port map (
            i_array => words,
            i_sel   => i_sel,
            o_d     => o_d
        );

end architecture rtl;
