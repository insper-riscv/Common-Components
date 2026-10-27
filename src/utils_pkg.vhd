-- =============================================================================
-- Pacote de tipos e funções utilitárias de hardware
--
-- Define o tipo de matriz de palavras (word_array_t) compatível com VHDL-2008
-- e funções auxiliares combinacionais para comparação de vetores (equals,
-- not_equals, is_equal_dynamic), inversão da ordem dos bits (reverse_vector),
-- redução OU e E em árvore (reduce_or, reduce_and) e cálculo de largura de
-- endereço em tempo de elaboração (log2_ceil).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

package utils_pkg is

  -- Matriz não-constrangida de palavras de dados (compatível com VHDL-2008).
  type word_array_t is array (natural range <>) of std_logic_vector;

  -- Retorna '1' quando os vetores a e b são bit a bit iguais, e '0' caso contrário.
  function equals(a : in std_logic_vector; b : in std_logic_vector) return std_logic;

  -- Retorna '1' quando os vetores a e b diferem em pelo menos um bit, e '0' caso contrário.
  function not_equals(a : in std_logic_vector; b : in std_logic_vector) return std_logic;

  -- Retorna '1' quando os vetores l e r são bit a bit iguais, reduzindo o XNOR dos dois com um E em árvore.
  function is_equal_dynamic(l : in std_logic_vector; r : in std_logic_vector) return std_logic;

  -- Retorna o vetor l com a ordem dos bits invertida: o bit mais significativo passa a ser o menos significativo.
  function reverse_vector(l : in std_logic_vector) return std_logic_vector;

  -- Reduz o vetor l com OU em estrutura de árvore, de profundidade O(log n), o que deixa os diagramas RTL mais compactos que a cadeia encadeada da biblioteca IEEE.
  function reduce_or(l : in std_logic_vector) return std_logic;

  -- Reduz o vetor l com E em estrutura de árvore, de profundidade O(log n).
  function reduce_and(l : in std_logic_vector) return std_logic;

  -- Calcula o menor inteiro natural n tal que 2^n >= arg.
  function log2_ceil(arg : positive) return natural;

end package;

package body utils_pkg is 

function equals(a : in std_logic_vector; b : in std_logic_vector) return std_logic is

	alias av : std_logic_vector(a'length - 1 downto 0) is a;
	alias bv : std_logic_vector(b'length - 1 downto 0) is b;

	-- Variavel para o resultado acumulado do AND
	variable result : std_logic := '1';

	begin
	-- 1. Realiza a comparacao bit a bit usando XNOR	  
	-- 2. Combina os resultados com uma operacao AND
		for i in av'range loop

			result := result and (av(i) xnor bv(i));

		end loop;

	return result;

end function equals;

function not_equals(a : in std_logic_vector; b : in std_logic_vector) return std_logic is

	alias av : std_logic_vector(a'length - 1 downto 0) is a;
	alias bv : std_logic_vector(b'length - 1 downto 0) is b;

	-- Variavel para o resultado acumulado do OR
	variable result : std_logic := '0';

	begin
	-- 1. Realiza a comparacao bit a bit usando XOR	  
	-- 2. Combina os resultados com uma operacao OR
		for i in av'range loop

			result := result or (av(i) xor bv(i));

		end loop;

	return result;

end function not_equals;

function reverse_vector(l : in std_logic_vector) return std_logic_vector is

	variable result : std_logic_vector(l'range);
	alias auxiliar  : std_logic_vector(l'reverse_range) is l;

	begin

		for i in auxiliar'range loop

			result(i) := auxiliar(i);

		end loop;

	return result;

end function reverse_vector;

function reduce_or(l : in std_logic_vector) return std_logic is

	constant mid : integer := (l'high + l'low) / 2;

	begin

		if l'length = 1 then

			return l(l'low);

		elsif l'length = 2 then

			return l(l'low) or l(l'high);

		elsif l'ascending then

			return reduce_or(l((mid + 1) to l'high)) or reduce_or(l(l'low to mid));

		else

			return reduce_or(l(l'high downto (mid + 1))) or reduce_or(l(mid downto l'low));

		end if;

end function reduce_or;

function reduce_and(l : in std_logic_vector) return std_logic is

	constant mid : integer := (l'high + l'low) / 2;

	begin

		if l'length = 1 then

			return l(l'low);

		elsif l'length = 2 then

			return l(l'low) and l(l'high);

		elsif l'ascending then

			return reduce_and(l((mid + 1) to l'high)) and reduce_and(l(l'low to mid));

		else

			return reduce_and(l(l'high downto (mid + 1))) and reduce_and(l(mid downto l'low));

		end if;

end function reduce_and;

function is_equal_dynamic(l : in std_logic_vector; r : in std_logic_vector) return std_logic is

	begin

		return reduce_and(l xnor r);

end function is_equal_dynamic;

function log2_ceil(arg : positive) return natural is
	
	variable result : natural := 0;
	
	begin
	
		while (2**result) < arg loop
		
			result := result + 1;
			
		end loop;
		
	return result;
	
end function log2_ceil;

end package body;