-- =============================================================================
-- Multiplexador 32x1 parametrizável
--
-- Seleciona combinacionalmente entre 32 barramentos de entrada de largura
-- configurável (data_width) de acordo com o seletor i_sel de 5 bits: com k o
-- valor numérico de i_sel, o_d recebe i_dk. A seleção é feita pelo mux_tree.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity mux_32x1 is
    generic (
        -- Largura dos barramentos de dados (em bits).
        data_width : natural := 8
    );
    port (
        -- Entrada de dados 0 (selecionada quando i_sel vale 0).
        i_d0  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 1 (selecionada quando i_sel vale 1).
        i_d1  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 2 (selecionada quando i_sel vale 2).
        i_d2  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 3 (selecionada quando i_sel vale 3).
        i_d3  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 4 (selecionada quando i_sel vale 4).
        i_d4  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 5 (selecionada quando i_sel vale 5).
        i_d5  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 6 (selecionada quando i_sel vale 6).
        i_d6  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 7 (selecionada quando i_sel vale 7).
        i_d7  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 8 (selecionada quando i_sel vale 8).
        i_d8  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 9 (selecionada quando i_sel vale 9).
        i_d9  : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 10 (selecionada quando i_sel vale 10).
        i_d10 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 11 (selecionada quando i_sel vale 11).
        i_d11 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 12 (selecionada quando i_sel vale 12).
        i_d12 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 13 (selecionada quando i_sel vale 13).
        i_d13 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 14 (selecionada quando i_sel vale 14).
        i_d14 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 15 (selecionada quando i_sel vale 15).
        i_d15 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 16 (selecionada quando i_sel vale 16).
        i_d16 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 17 (selecionada quando i_sel vale 17).
        i_d17 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 18 (selecionada quando i_sel vale 18).
        i_d18 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 19 (selecionada quando i_sel vale 19).
        i_d19 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 20 (selecionada quando i_sel vale 20).
        i_d20 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 21 (selecionada quando i_sel vale 21).
        i_d21 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 22 (selecionada quando i_sel vale 22).
        i_d22 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 23 (selecionada quando i_sel vale 23).
        i_d23 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 24 (selecionada quando i_sel vale 24).
        i_d24 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 25 (selecionada quando i_sel vale 25).
        i_d25 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 26 (selecionada quando i_sel vale 26).
        i_d26 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 27 (selecionada quando i_sel vale 27).
        i_d27 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 28 (selecionada quando i_sel vale 28).
        i_d28 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 29 (selecionada quando i_sel vale 29).
        i_d29 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 30 (selecionada quando i_sel vale 30).
        i_d30 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 31 (selecionada quando i_sel vale 31).
        i_d31 : in    std_logic_vector((data_width - 1) downto 0);
        -- Seletor da entrada que chega à saída.
        i_sel : in    std_logic_vector(4 downto 0);
        -- Saída de dados selecionada.
        o_d   : out   std_logic_vector((data_width - 1) downto 0)
    );
end entity mux_32x1;

architecture rtl of mux_32x1 is

    -- Matriz com as 32 entradas, na ordem do índice de seleção.
    signal s_array : word_array_t(31 downto 0)((data_width - 1) downto 0);

begin

    s_array(0)  <= i_d0;
    s_array(1)  <= i_d1;
    s_array(2)  <= i_d2;
    s_array(3)  <= i_d3;
    s_array(4)  <= i_d4;
    s_array(5)  <= i_d5;
    s_array(6)  <= i_d6;
    s_array(7)  <= i_d7;
    s_array(8)  <= i_d8;
    s_array(9)  <= i_d9;
    s_array(10) <= i_d10;
    s_array(11) <= i_d11;
    s_array(12) <= i_d12;
    s_array(13) <= i_d13;
    s_array(14) <= i_d14;
    s_array(15) <= i_d15;
    s_array(16) <= i_d16;
    s_array(17) <= i_d17;
    s_array(18) <= i_d18;
    s_array(19) <= i_d19;
    s_array(20) <= i_d20;
    s_array(21) <= i_d21;
    s_array(22) <= i_d22;
    s_array(23) <= i_d23;
    s_array(24) <= i_d24;
    s_array(25) <= i_d25;
    s_array(26) <= i_d26;
    s_array(27) <= i_d27;
    s_array(28) <= i_d28;
    s_array(29) <= i_d29;
    s_array(30) <= i_d30;
    s_array(31) <= i_d31;

    u_tree : entity work.mux_tree
        generic map (
            data_width     => data_width,
            selector_width => 5
        )
        port map (
            i_array => s_array,
            i_sel   => i_sel,
            o_d     => o_d
        );

end architecture rtl;
