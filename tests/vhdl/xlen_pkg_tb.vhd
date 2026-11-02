-- =============================================================================
-- Invólucro de teste do xlen_pkg
--
-- Instancia o pacote genérico nas quatro combinações de base e largura
-- (RV32I, RV32E, RV64I e RV64E) e expõe como portas a largura de word_t, a
-- largura de reg_t e o número de registradores de cada instância, para que o
-- cocotb as confira.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Instância do pacote para a base I com 32 bits.
package rv32i_p is new work.xlen_pkg generic map (xlen => 32, rve => false);
-- Instância do pacote para a base E com 32 bits.
package rv32e_p is new work.xlen_pkg generic map (xlen => 32, rve => true);
-- Instância do pacote para a base I com 64 bits.
package rv64i_p is new work.xlen_pkg generic map (xlen => 64, rve => false);
-- Instância do pacote para a base E com 64 bits.
package rv64e_p is new work.xlen_pkg generic map (xlen => 64, rve => true);

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xlen_pkg_tb is
	port (
		-- Largura de word_t da instância RV32I.
		o_rv32i_word : out std_logic_vector(7 downto 0);
		-- Largura de reg_t da instância RV32I.
		o_rv32i_reg  : out std_logic_vector(7 downto 0);
		-- Número de registradores da instância RV32I.
		o_rv32i_regs : out std_logic_vector(7 downto 0);
		-- Largura de word_t da instância RV32E.
		o_rv32e_word : out std_logic_vector(7 downto 0);
		-- Largura de reg_t da instância RV32E.
		o_rv32e_reg  : out std_logic_vector(7 downto 0);
		-- Número de registradores da instância RV32E.
		o_rv32e_regs : out std_logic_vector(7 downto 0);
		-- Largura de word_t da instância RV64I.
		o_rv64i_word : out std_logic_vector(7 downto 0);
		-- Largura de reg_t da instância RV64I.
		o_rv64i_reg  : out std_logic_vector(7 downto 0);
		-- Número de registradores da instância RV64I.
		o_rv64i_regs : out std_logic_vector(7 downto 0);
		-- Largura de word_t da instância RV64E.
		o_rv64e_word : out std_logic_vector(7 downto 0);
		-- Largura de reg_t da instância RV64E.
		o_rv64e_reg  : out std_logic_vector(7 downto 0);
		-- Número de registradores da instância RV64E.
		o_rv64e_regs : out std_logic_vector(7 downto 0)
	);
end entity xlen_pkg_tb;

architecture rtl of xlen_pkg_tb is

	-- Palavra do RV64I toda em '1', para provar que word_t é um vetor utilizável como tipo de constante.
	constant WORD_RV64I_ONES : work.rv64i_p.word_t := (others => '1');
	-- Índice de registrador do RV32E todo em '1', para provar que reg_t é um vetor utilizável como tipo de constante.
	constant REG_RV32E_ONES  : work.rv32e_p.reg_t := (others => '1');


begin

	o_rv32i_word <= std_logic_vector(to_unsigned(work.rv32i_p.word_t'length, 8));
	o_rv32i_reg  <= std_logic_vector(to_unsigned(work.rv32i_p.reg_t'length, 8));
	o_rv32i_regs <= std_logic_vector(to_unsigned(work.rv32i_p.NUM_REGS, 8));
	o_rv32e_word <= std_logic_vector(to_unsigned(work.rv32e_p.word_t'length, 8));
	o_rv32e_reg  <= std_logic_vector(to_unsigned(REG_RV32E_ONES'length, 8));
	o_rv32e_regs <= std_logic_vector(to_unsigned(work.rv32e_p.NUM_REGS, 8));
	o_rv64i_word <= std_logic_vector(to_unsigned(WORD_RV64I_ONES'length, 8));
	o_rv64i_reg  <= std_logic_vector(to_unsigned(work.rv64i_p.reg_t'length, 8));
	o_rv64i_regs <= std_logic_vector(to_unsigned(work.rv64i_p.NUM_REGS, 8));
	o_rv64e_word <= std_logic_vector(to_unsigned(work.rv64e_p.word_t'length, 8));
	o_rv64e_reg  <= std_logic_vector(to_unsigned(work.rv64e_p.reg_t'length, 8));
	o_rv64e_regs <= std_logic_vector(to_unsigned(work.rv64e_p.NUM_REGS, 8));

end architecture rtl;
