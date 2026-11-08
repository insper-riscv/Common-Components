-- =============================================================================
-- Invólucro de teste do config_pkg
--
-- Expõe como portas as larguras e as constantes derivadas do config_pkg da
-- lista de fontes (a padrão, ou uma variante gerada que a substitui), para
-- que o cocotb e as provas formais as conferam: XLEN, REG_BITS, NUM_REGS,
-- ADDR_BITS, o comprimento de cada subtipo, as constantes compostas, o mapa
-- de memória e o nome da ISA. A chamada de check_isa fica no generate, de
-- modo que uma configuração inválida falha na elaboração.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.config_pkg.all;

entity config_pkg_tb is
	port (
		-- Valor de XLEN.
		o_xlen            : out   std_logic_vector(7 downto 0);
		-- Valor de REG_BITS.
		o_reg_bits        : out   std_logic_vector(7 downto 0);
		-- Valor de NUM_REGS.
		o_num_regs        : out   std_logic_vector(7 downto 0);
		-- Valor de ADDR_BITS.
		o_addr_bits       : out   std_logic_vector(7 downto 0);
		-- Comprimento de word_t.
		o_word_len        : out   std_logic_vector(7 downto 0);
		-- Comprimento de reg_t.
		o_reg_len         : out   std_logic_vector(7 downto 0);
		-- Comprimento de addr_t.
		o_addr_len        : out   std_logic_vector(7 downto 0);
		-- Comprimento de map_addr_t.
		o_map_len         : out   std_logic_vector(7 downto 0);
		-- Valor de IS_64.
		o_is_64           : out   std_logic;
		-- Valor de IS_BASE_E.
		o_is_base_e       : out   std_logic;
		-- Valor de HAS_MULDIV.
		o_has_muldiv      : out   std_logic;
		-- Valor de HAS_ANY_COUNTER.
		o_has_any_counter : out   std_logic;
		-- Valor de HAS_SSCOF.
		o_has_sscof       : out   std_logic;
		-- Vale '1' quando check_isa aceitou a configuração.
		o_isa_ok          : out   std_logic;
		-- Base da ROM em bytes.
		o_rom_base        : out   std_logic_vector(ADDR_BITS downto 0);
		-- Fim exclusivo da ROM em bytes.
		o_rom_end         : out   std_logic_vector(ADDR_BITS downto 0);
		-- Base da RAM em bytes.
		o_ram_base        : out   std_logic_vector(ADDR_BITS downto 0);
		-- Fim exclusivo da RAM em bytes.
		o_ram_end         : out   std_logic_vector(ADDR_BITS downto 0);
		-- Base da janela externa em bytes.
		o_ext_base        : out   std_logic_vector(ADDR_BITS downto 0);
		-- Base da janela de periféricos em bytes.
		o_periph_base     : out   std_logic_vector(ADDR_BITS downto 0);
		-- Nome da ISA (isa_string) nos 16 primeiros caracteres, ASCII, completado com espaços.
		o_isa             : out   std_logic_vector(127 downto 0)
	);
end entity config_pkg_tb;

architecture rtl of config_pkg_tb is

	-- Número de caracteres de o_isa.
	constant ISA_CHARS : natural := 16;

	-- Codifica os primeiros ISA_CHARS caracteres de isa_string em ASCII, completando com espaços.

	function isa_bits return std_logic_vector is

		-- Texto da ISA.
		constant TEXT    : string := isa_string;
		-- Resultado codificado.
		variable result  : std_logic_vector((ISA_CHARS * 8 - 1) downto 0);
		-- Caractere lido, com espaço depois do fim do texto.
		variable char    : character;
		-- Posição do bit menos significativo do caractere i dentro do resultado.
		variable low_bit : natural;

	begin

		for i in 0 to (ISA_CHARS - 1) loop

			if i < TEXT'length then
				char := TEXT(TEXT'left + i);
			else
				char := ' ';
			end if;

			low_bit                              := (ISA_CHARS - 1 - i) * 8;
			result((low_bit + 7) downto low_bit) := std_logic_vector(to_unsigned(character'pos(char), 8));

		end loop;

		return result;

	end function isa_bits;

begin

	o_xlen      <= std_logic_vector(to_unsigned(XLEN, 8));
	o_reg_bits  <= std_logic_vector(to_unsigned(REG_BITS, 8));
	o_num_regs  <= std_logic_vector(to_unsigned(NUM_REGS, 8));
	o_addr_bits <= std_logic_vector(to_unsigned(ADDR_BITS, 8));
	o_word_len  <= std_logic_vector(to_unsigned(word_t'length, 8));
	o_reg_len   <= std_logic_vector(to_unsigned(reg_t'length, 8));
	o_addr_len  <= std_logic_vector(to_unsigned(addr_t'length, 8));
	o_map_len   <= std_logic_vector(to_unsigned(map_addr_t'length, 8));

	o_is_64           <= to_sl(IS_64);
	o_is_base_e       <= to_sl(IS_BASE_E);
	o_has_muldiv      <= to_sl(HAS_MULDIV);
	o_has_any_counter <= to_sl(HAS_ANY_COUNTER);
	o_has_sscof       <= to_sl(HAS_SSCOF);

	o_rom_base    <= std_logic_vector(ROM_BASE);
	o_rom_end     <= std_logic_vector(ROM_END);
	o_ram_base    <= std_logic_vector(RAM_BASE);
	o_ram_end     <= std_logic_vector(RAM_END);
	o_ext_base    <= std_logic_vector(EXT_BASE);
	o_periph_base <= std_logic_vector(PERIPH_BASE);

	o_isa <= isa_bits;

	gen_check : if check_isa generate
		o_isa_ok <= '1';
	end generate gen_check;

end architecture rtl;
