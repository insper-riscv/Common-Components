-- =============================================================================
-- Multiplexador 64x1 parametrizável
--
-- Seleciona combinacionalmente entre 64 barramentos de entrada de largura
-- configurável (data_width) de acordo com o seletor i_sel de 6 bits: com k o
-- valor numérico de i_sel, o_d recebe i_dk. A seleção é feita pelo mux_tree.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity mux_64x1 is
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
        -- Entrada de dados 32 (selecionada quando i_sel vale 32).
        i_d32 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 33 (selecionada quando i_sel vale 33).
        i_d33 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 34 (selecionada quando i_sel vale 34).
        i_d34 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 35 (selecionada quando i_sel vale 35).
        i_d35 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 36 (selecionada quando i_sel vale 36).
        i_d36 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 37 (selecionada quando i_sel vale 37).
        i_d37 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 38 (selecionada quando i_sel vale 38).
        i_d38 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 39 (selecionada quando i_sel vale 39).
        i_d39 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 40 (selecionada quando i_sel vale 40).
        i_d40 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 41 (selecionada quando i_sel vale 41).
        i_d41 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 42 (selecionada quando i_sel vale 42).
        i_d42 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 43 (selecionada quando i_sel vale 43).
        i_d43 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 44 (selecionada quando i_sel vale 44).
        i_d44 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 45 (selecionada quando i_sel vale 45).
        i_d45 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 46 (selecionada quando i_sel vale 46).
        i_d46 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 47 (selecionada quando i_sel vale 47).
        i_d47 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 48 (selecionada quando i_sel vale 48).
        i_d48 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 49 (selecionada quando i_sel vale 49).
        i_d49 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 50 (selecionada quando i_sel vale 50).
        i_d50 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 51 (selecionada quando i_sel vale 51).
        i_d51 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 52 (selecionada quando i_sel vale 52).
        i_d52 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 53 (selecionada quando i_sel vale 53).
        i_d53 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 54 (selecionada quando i_sel vale 54).
        i_d54 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 55 (selecionada quando i_sel vale 55).
        i_d55 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 56 (selecionada quando i_sel vale 56).
        i_d56 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 57 (selecionada quando i_sel vale 57).
        i_d57 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 58 (selecionada quando i_sel vale 58).
        i_d58 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 59 (selecionada quando i_sel vale 59).
        i_d59 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 60 (selecionada quando i_sel vale 60).
        i_d60 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 61 (selecionada quando i_sel vale 61).
        i_d61 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 62 (selecionada quando i_sel vale 62).
        i_d62 : in    std_logic_vector((data_width - 1) downto 0);
        -- Entrada de dados 63 (selecionada quando i_sel vale 63).
        i_d63 : in    std_logic_vector((data_width - 1) downto 0);
        -- Seletor da entrada que chega à saída.
        i_sel : in    std_logic_vector(5 downto 0);
        -- Saída de dados selecionada.
        o_d   : out   std_logic_vector((data_width - 1) downto 0)
    );
end entity mux_64x1;

architecture rtl of mux_64x1 is

    -- Matriz com as 64 entradas, na ordem do índice de seleção.
    signal s_array : word_array_t(63 downto 0)((data_width - 1) downto 0);

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
    s_array(32) <= i_d32;
    s_array(33) <= i_d33;
    s_array(34) <= i_d34;
    s_array(35) <= i_d35;
    s_array(36) <= i_d36;
    s_array(37) <= i_d37;
    s_array(38) <= i_d38;
    s_array(39) <= i_d39;
    s_array(40) <= i_d40;
    s_array(41) <= i_d41;
    s_array(42) <= i_d42;
    s_array(43) <= i_d43;
    s_array(44) <= i_d44;
    s_array(45) <= i_d45;
    s_array(46) <= i_d46;
    s_array(47) <= i_d47;
    s_array(48) <= i_d48;
    s_array(49) <= i_d49;
    s_array(50) <= i_d50;
    s_array(51) <= i_d51;
    s_array(52) <= i_d52;
    s_array(53) <= i_d53;
    s_array(54) <= i_d54;
    s_array(55) <= i_d55;
    s_array(56) <= i_d56;
    s_array(57) <= i_d57;
    s_array(58) <= i_d58;
    s_array(59) <= i_d59;
    s_array(60) <= i_d60;
    s_array(61) <= i_d61;
    s_array(62) <= i_d62;
    s_array(63) <= i_d63;

    u_tree : entity work.mux_tree
        generic map (
            data_width     => data_width,
            selector_width => 6
        )
        port map (
            i_array => s_array,
            i_sel   => i_sel,
            o_d     => o_d
        );

end architecture rtl;
