-- =============================================================================
-- Buffer de três estados de 1 bit
--
-- Conecta a entrada à saída quando i_enable = '1' e coloca a saída em alta
-- impedância ('Z') quando i_enable = '0', para que vários drivers dividam um
-- mesmo pino ou barramento bidirecional.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity tristate_buffer_1bit is
	port (
		-- Dado a ser conduzido quando o buffer está habilitado.
		i_d      : in  std_logic;
		-- Habilitação do driver ('1' conduz i_d, '0' deixa a saída em alta impedância).
		i_enable : in  std_logic;
		-- Saída de três estados.
		o_d      : out std_logic
	);
end entity tristate_buffer_1bit;

architecture rtl of tristate_buffer_1bit is
begin

	o_d <= i_d when i_enable = '1' else 'Z';

end architecture rtl;
