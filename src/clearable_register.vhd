-- =============================================================================
-- Registrador paralelo com clear síncrono e habilitação
--
-- Compõe o generic_register: o clear síncrono é a carga de um valor fixo no
-- ciclo em que i_clear = '1', sem reset assíncrono.
--
-- Prioridade de operação na borda de subida de i_clk:
--   1. i_clear = '1' -> o_d recebe o valor de limpeza (todos os bits em clear_value).
--   2. i_enable = '1' -> o_d recebe i_d.
--   3. Caso contrário, o_d mantém o valor atual.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity clearable_register is
	generic (
		-- Largura do registrador (em bits).
		data_width  : natural   := 32;
		-- Valor de cada bit após o clear ('0' zera o registrador, '1' o preenche com uns).
		clear_value : std_logic := '0'
	);
	port (
		-- Clock do sistema (borda de subida).
		i_clk    : in  std_logic;
		-- Clear síncrono ('1' carrega o valor de limpeza, com prioridade sobre i_enable).
		i_clear  : in  std_logic;
		-- Habilitação de carga ('1' grava i_d).
		i_enable : in  std_logic;
		-- Dado a ser gravado.
		i_d      : in  std_logic_vector((data_width - 1) downto 0);
		-- Valor armazenado.
		o_d      : out std_logic_vector((data_width - 1) downto 0)
	);
end entity clearable_register;

architecture rtl of clearable_register is

	-- Sem reset assíncrono: o generic_register recebe '0' em i_rst.
	constant NO_RESET : std_logic := '0';

	-- Habilitação do registrador interno: carrega no clear ou na escrita.
	signal load_enable : std_logic;
	-- Dado do registrador interno: o valor de limpeza no clear, senão i_d.
	signal load_data   : std_logic_vector((data_width - 1) downto 0);

begin

	load_enable <= i_clear or i_enable;
	load_data   <= (others => clear_value) when i_clear = '1' else i_d;

	u_register : entity work.generic_register
		generic map (
			data_width => data_width
		)
		port map (
			i_d      => load_data,
			o_d      => o_d,
			i_enable => load_enable,
			i_clk    => i_clk,
			i_rst    => NO_RESET
		);

end architecture rtl;
