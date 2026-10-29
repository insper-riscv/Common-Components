-- =============================================================================
-- Sincronizador de cruzamento de domínios de clock
--
-- Leva um sinal gerado em outro domínio de clock para o domínio de i_clk por
-- uma cadeia de flip-flops em série (stages, no mínimo 2). Só o último estágio
-- chega a o_d, e os anteriores têm um período inteiro de i_clk para sair da
-- metaestabilidade; cada estágio a mais reduz a probabilidade de falha, ao custo
-- de um ciclo de latência.
--
-- Latência: o_d reflete i_d depois de stages bordas de subida de i_clk.
--
-- Reset síncrono opcional: com i_rst = '1' na borda de subida de i_clk, todos os
-- estágios vão a '0', e o reset tem prioridade sobre a entrada. Sem ligar
-- i_rst, a cadeia só carrega o valor inicial '0' da elaboração.
--
-- Cada bit de i_d é sincronizado de forma independente, e os bits podem chegar
-- em ciclos diferentes. Por isso o sincronizador só serve para:
--   - um bit de nível ou de pulso longo (mais de um período de i_clk);
--   - um toggle de handshake (a cada inversão, um pedido ou uma resposta);
--   - um vetor cujos bits são consumidos sozinhos ou codificados em Gray.
-- Um barramento de dados nunca atravessa por aqui: ele fica parado e é lido só
-- depois que o toggle que o acompanha chega sincronizado.
--
-- No Quartus, o atributo altera_attribute marca a cadeia como sincronizador
-- (entra no relatório de MTBF) e impede que os registradores sejam fundidos ou
-- removidos. O caminho que entra no primeiro estágio deve ter set_false_path ou
-- set_max_delay no .sdc, pois não existe relação de fase entre os clocks.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
	generic (
		-- Número de flip-flops em série (no mínimo 2).
		stages     : natural := 2;
		-- Largura de i_d e o_d (em bits); cada bit é sincronizado sozinho.
		data_width : natural := 1
	);
	port (
		-- Clock do domínio de destino, o mesmo que consome o_d.
		i_clk : in  std_logic;
		-- Reset síncrono em i_clk, ativo em '1' (zera todos os estágios).
		i_rst : in  std_logic := '0';
		-- Sinal vindo do outro domínio de clock.
		i_d   : in  std_logic_vector((data_width - 1) downto 0);
		-- Sinal sincronizado com i_clk, atrasado de stages ciclos.
		o_d   : out std_logic_vector((data_width - 1) downto 0)
	);
end entity synchronizer;

architecture rtl of synchronizer is

	-- Vetor de uma palavra de data_width bits por estágio.
	type chain_t is array (0 to stages - 1) of std_logic_vector((data_width - 1) downto 0);

	-- Cadeia de estágios; o índice 0 amostra i_d e o último alimenta o_d.
	signal chain : chain_t := (others => (others => '0'));

	-- Marca a cadeia como sincronizador e preserva os registradores no Quartus.
	attribute altera_attribute : string;
	attribute altera_attribute of chain : signal is
		"-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON";

begin

	assert stages >= 2
		report "synchronizer: stages deve ser no mínimo 2"
		severity failure;

	-- Cada borda de i_clk empurra a cadeia um estágio adiante; o reset zera todos os estágios.
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			if i_rst = '1' then
				chain <= (others => (others => '0'));
			else
				chain(0) <= i_d;
				for i in 1 to stages - 1 loop
					chain(i) <= chain(i - 1);
				end loop;
			end if;
		end if;
	end process;

	o_d <= chain(stages - 1);

end architecture rtl;
