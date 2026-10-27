-- =============================================================================
-- Invólucro de teste do utils_pkg
--
-- Expõe como portas o resultado de cada função combinacional do pacote
-- (reverse_vector, reduce_or, reduce_and, is_equal_dynamic, equals e
-- not_equals) para que o cocotb as confira com vetores de 8 bits.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity utils_pkg_tb is
	port (
		-- Primeiro operando de 8 bits.
		i_a            : in  std_logic_vector(7 downto 0);
		-- Segundo operando de 8 bits.
		i_b            : in  std_logic_vector(7 downto 0);
		-- reverse_vector(i_a).
		o_reverse      : out std_logic_vector(7 downto 0);
		-- reduce_or(i_a).
		o_reduce_or    : out std_logic;
		-- reduce_and(i_a).
		o_reduce_and   : out std_logic;
		-- is_equal_dynamic(i_a, i_b).
		o_equal_dyn    : out std_logic;
		-- equals(i_a, i_b).
		o_equals       : out std_logic;
		-- not_equals(i_a, i_b).
		o_not_equals   : out std_logic
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

end architecture rtl;
