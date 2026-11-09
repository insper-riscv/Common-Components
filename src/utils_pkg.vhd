-- =============================================================================
-- Pacote de tipos e funções utilitárias de hardware
--
-- Define o tipo de matriz de palavras (word_array_t) compatível com VHDL-2008
-- e funções auxiliares combinacionais para comparação de vetores (equals,
-- not_equals, is_equal_dynamic), inversão da ordem dos bits (reverse_vector),
-- redução OU e E em árvore (reduce_or, reduce_and) e cálculo de largura de
-- endereço em tempo de elaboração (log2_ceil), mais a verificação de potência
-- de dois (is_power_of_two) e o logaritmo exato (log2_exact) que as memórias e
-- as caches usam para tornar o tamanho um genérico em potência de dois, mais a
-- conversão de condição booleana em bit (to_sl) e a escolha entre dois valores
-- por condição (pick).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

package utils_pkg is

    -- Matriz não-constrangida de palavras de dados (compatível com VHDL-2008).
    type word_array_t is array (natural range <>) of std_logic_vector;

    -- Retorna '1' quando os vetores a e b são bit a bit iguais, e '0' caso contrário.

    function equals (a : in std_logic_vector; b : in std_logic_vector) return std_logic;

    -- Retorna '1' quando os vetores a e b diferem em pelo menos um bit, e '0' caso contrário.

    function not_equals (a : in std_logic_vector; b : in std_logic_vector) return std_logic;

    -- Retorna '1' quando os vetores l e r são bit a bit iguais, reduzindo o XNOR dos dois com um E em árvore.

    function is_equal_dynamic (l : in std_logic_vector; r : in std_logic_vector) return std_logic;

    -- Retorna o vetor l com a ordem dos bits invertida: o bit mais significativo passa a ser o menos significativo.

    function reverse_vector (l : in std_logic_vector) return std_logic_vector;

    -- Reduz o vetor l com OU em estrutura de árvore, de profundidade O(log n), o que deixa os diagramas RTL mais
    -- compactos que a cadeia encadeada da biblioteca IEEE.

    function reduce_or (l : in std_logic_vector) return std_logic;

    -- Reduz o vetor l com E em estrutura de árvore, de profundidade O(log n).

    function reduce_and (l : in std_logic_vector) return std_logic;

    -- Calcula o menor inteiro natural n tal que 2^n >= arg.

    function log2_ceil (arg : positive) return natural;

    -- Retorna verdadeiro quando arg é uma potência de dois (1, 2, 4, 8, ...); zero não é.

    function is_power_of_two (arg : natural) return boolean;

    -- Calcula o n tal que 2^n = arg. Falha na elaboração quando arg não é uma potência de dois,
    -- para que um tamanho de memória ou de cache fora da regra não passe despercebido.

    function log2_exact (arg : positive) return natural;

    -- Converte a condição booleana b em std_logic: '1' quando b é verdadeiro e '0' quando é falso.

    function to_sl (b : in boolean) return std_logic;

    -- Escolhe entre dois valores naturais: devolve a quando cond é verdadeira e b caso contrário.

    function pick (cond : in boolean; a : in natural; b : in natural) return natural;

    -- Escolhe entre dois valores booleanos: devolve a quando cond é verdadeira e b caso contrário.

    function pick (cond : in boolean; a : in boolean; b : in boolean) return boolean;

end package utils_pkg;

package body utils_pkg is

    function equals (a : in std_logic_vector; b : in std_logic_vector) return std_logic is

        -- Visão de a normalizada para o índice descendente a partir de zero.
        alias av : std_logic_vector(a'length - 1 downto 0) is a;
        -- Visão de b normalizada para o índice descendente a partir de zero.
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

    function not_equals (a : in std_logic_vector; b : in std_logic_vector) return std_logic is

        -- Visão de a normalizada para o índice descendente a partir de zero.
        alias av : std_logic_vector(a'length - 1 downto 0) is a;
        -- Visão de b normalizada para o índice descendente a partir de zero.
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

    function reverse_vector (l : in std_logic_vector) return std_logic_vector is

        -- Vetor resultado com a ordem dos bits invertida.
        variable result   : std_logic_vector(l'range);
        -- Visão de l com a faixa invertida, lida na ordem original.
        alias    auxiliar : std_logic_vector(l'reverse_range) is l;

    begin

        for i in auxiliar'range loop

            result(i) := auxiliar(i);

        end loop;

        return result;

    end function reverse_vector;

    function reduce_or (l : in std_logic_vector) return std_logic is

        -- Índice do meio do vetor, que divide a redução OU em duas metades.
        constant MID : integer := (l'high + l'low) / 2;

    begin

        if l'length = 1 then
            return l(l'low);
        elsif l'length = 2 then
            return l(l'low) or l(l'high);
        elsif l'ascending then
            return reduce_or(l((MID + 1) to l'high)) or reduce_or(l(l'low to MID));
        else
            return reduce_or(l(l'high downto (MID + 1))) or reduce_or(l(MID downto l'low));
        end if;

    end function reduce_or;

    function reduce_and (l : in std_logic_vector) return std_logic is

        -- Índice do meio do vetor, que divide a redução E em duas metades.
        constant MID : integer := (l'high + l'low) / 2;

    begin

        if l'length = 1 then
            return l(l'low);
        elsif l'length = 2 then
            return l(l'low) and l(l'high);
        elsif l'ascending then
            return reduce_and(l((MID + 1) to l'high)) and reduce_and(l(l'low to MID));
        else
            return reduce_and(l(l'high downto (MID + 1))) and reduce_and(l(MID downto l'low));
        end if;

    end function reduce_and;

    function is_equal_dynamic (l : in std_logic_vector; r : in std_logic_vector) return std_logic is

    begin

        return reduce_and(l xnor r);

    end function is_equal_dynamic;

    function log2_ceil (arg : positive) return natural is

        -- Contador do expoente, o primeiro n tal que 2^n >= arg.
        variable result : natural := 0;

    begin

        while (2 ** result) < arg loop

            result := result + 1;

        end loop;

        return result;

    end function log2_ceil;

    function is_power_of_two (arg : natural) return boolean is

    begin

        if arg = 0 then
            return false;
        end if;

        return (2 ** log2_ceil(arg)) = arg;

    end function is_power_of_two;

    function log2_exact (arg : positive) return natural is

    begin

        assert is_power_of_two(arg)
            report "log2_exact: " & integer'image(arg) & " is not a power of two"
            severity failure;

        return log2_ceil(arg);

    end function log2_exact;

    function to_sl (b : in boolean) return std_logic is

    begin

        if b then
            return '1';
        else
            return '0';
        end if;

    end function to_sl;

    function pick (cond : in boolean; a : in natural; b : in natural) return natural is

    begin

        if cond then
            return a;
        else
            return b;
        end if;

    end function pick;

    function pick (cond : in boolean; a : in boolean; b : in boolean) return boolean is

    begin

        if cond then
            return a;
        else
            return b;
        end if;

    end function pick;

end package body utils_pkg;
