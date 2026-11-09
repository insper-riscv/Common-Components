-- =============================================================================
-- Invólucro de teste do utils_pkg
--
-- Expõe como portas o resultado de cada função combinacional do pacote
-- (reverse_vector, reduce_or, reduce_and, is_equal_dynamic, equals e
-- not_equals) para que o cocotb as confira com vetores de 8 bits, e o de
-- is_power_of_two e log2_exact para o valor de i_a lido como inteiro, e o de
-- to_sl e de pick (natural e boolean) para a condição i_a = i_b.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity utils_pkg_tb is
    port (
        -- Primeiro operando de 8 bits.
        i_a          : in    std_logic_vector(7 downto 0);
        -- Segundo operando de 8 bits.
        i_b          : in    std_logic_vector(7 downto 0);
        -- reverse_vector(i_a).
        o_reverse    : out   std_logic_vector(7 downto 0);
        -- reduce_or(i_a).
        o_reduce_or  : out   std_logic;
        -- reduce_and(i_a).
        o_reduce_and : out   std_logic;
        -- is_equal_dynamic(i_a, i_b).
        o_equal_dyn  : out   std_logic;
        -- equals(i_a, i_b).
        o_equals     : out   std_logic;
        -- not_equals(i_a, i_b).
        o_not_equals : out   std_logic;
        -- is_power_of_two(i_a lido como inteiro).
        o_is_pow2    : out   std_logic;
        -- log2_exact(i_a lido como inteiro) quando i_a é potência de dois, 15 nos demais casos.
        o_log2       : out   std_logic_vector(3 downto 0);
        -- to_sl(i_a = i_b).
        o_to_sl      : out   std_logic;
        -- pick(i_a = i_b, 1, 0) lido como bit.
        o_pick_nat   : out   std_logic;
        -- pick(i_a = i_b, false, true) lido como bit.
        o_pick_bool  : out   std_logic;
        -- pick(i_a = i_b, 0, 0) lido como bit, o caso de valores iguais.
        o_pick_same  : out   std_logic
    );
end entity utils_pkg_tb;

architecture rtl of utils_pkg_tb is

begin

    o_reverse    <= reverse_vector(i_a);
    o_reduce_or  <= reduce_or(i_a);
    o_reduce_and <= reduce_and(i_a);
    o_equal_dyn  <= is_equal_dynamic(i_a, i_b);
    o_equals     <= equals(i_a, i_b);
    o_not_equals <= not_equals(i_a, i_b);

    o_is_pow2 <= '1' when is_power_of_two(to_integer(unsigned(i_a))) else '0';

    o_to_sl <= to_sl(i_a = i_b);

    o_pick_nat  <= '1' when pick(i_a = i_b, 1, 0) = 1 else '0';
    o_pick_bool <= to_sl(pick(i_a = i_b, false, true));
    o_pick_same <= '1' when pick(i_a = i_b, 0, 0) = 1 else '0';

    o_log2 <= std_logic_vector(to_unsigned(log2_exact(to_integer(unsigned(i_a))), 4))
              when is_power_of_two(to_integer(unsigned(i_a))) else
              x"F";

end architecture rtl;
