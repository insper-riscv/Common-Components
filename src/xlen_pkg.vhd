-- ============================================================================
-- Pacote genérico de larguras da ISA (XLEN e banco de registradores)
-- ============================================================================
-- Pacote genérico do VHDL-2008 que fixa, na instanciação, a largura do dado
-- (XLEN de 32 ou 64 bits) e a largura do índice de registrador (5 bits na
-- base I e 4 bits na base E). Quem o usa instancia o pacote uma vez, com os
-- valores do seu perfil, e passa a ter os subtipos word_t e reg_t:
--
--   package isa_p is new work.xlen_pkg generic map (xlen => 64, rve => false);
--
-- Só 32 e 64 são larguras válidas de xlen; a entidade que instancia o pacote
-- confere o valor com um assert, pois um pacote não executa assertivas.
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;

package xlen_pkg is

  generic (
    -- Largura em bits do dado, do PC e dos registradores: 32 (RV32) ou 64 (RV64)
    xlen : natural := 32;
    -- Quando verdadeiro, a base é a E e o índice de registrador tem 4 bits; quando falso, a base é a I e tem 5 bits
    rve  : boolean := false
  );

  -- Largura em bits da palavra de dados, igual ao generic xlen.
  constant WORD_BITS : natural := xlen;

  -- Largura em bits do índice de registrador: 4 na base E e 5 na base I.
  constant REG_ADDR_BITS : natural := 5 - boolean'pos(rve);

  -- Quantidade de registradores de uso geral do banco: 2 elevado a REG_ADDR_BITS.
  constant NUM_REGS : natural := 2 ** REG_ADDR_BITS;

  -- Palavra de dados de xlen bits (32 ou 64).
  subtype word_t is std_logic_vector(WORD_BITS - 1 downto 0);

  -- Índice de registrador de uso geral (5 bits na base I, 4 bits na base E).
  subtype reg_t is std_logic_vector(REG_ADDR_BITS - 1 downto 0);

end package xlen_pkg;
