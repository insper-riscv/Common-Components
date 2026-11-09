# mux_tree

🌐 [Português](../../pt-br/multiplexers/mux_tree.md) · [English](../../en/multiplexers/mux_tree.md)

## 1. Finalidade

Multiplexador de $2^{S}$ entradas organizado como árvore balanceada, com $S$ igual ao genérico `selector_width`. Cada estágio consome $B$ bits do seletor, com $B$ igual ao genérico `stage_bits`, e escolhe entre $2^{B}$ palavras adjacentes do estágio anterior. Com $B = 1$ a árvore é binária, de estágios 2x1; com $B = 2$, de estágios 4x1; com $B = 3$, de estágios 8x1. O bloco não conhece o dispositivo de destino: `stage_bits` escolhe apenas a estrutura, e o resultado funcional é o mesmo para qualquer valor.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Largura de cada palavra, em bits. |
| `selector_width` | `natural` | `5` | Largura do seletor, em bits. O número de palavras de entrada é $2^{S}$. |
| `stage_bits` | `positive` | `1` | Bits do seletor consumidos por estágio. Um valor maior que `selector_width` resulta em um único estágio. Zero é recusado na elaboração. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_array` | in | `word_array_t(2**selector_width-1 downto 0)(data_width-1 downto 0)` | Matriz de palavras de entrada, tipo definido no `utils_pkg`. |
| `i_sel` | in | `std_logic_vector(selector_width-1 downto 0)` | Índice binário da palavra escolhida. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Palavra selecionada. |

## 4. Comportamento

O nível 0 recebe a matriz de entrada. A árvore tem $N = \lceil S / B \rceil$ estágios. O estágio $s$ consome os bits de $c_s = \min(sB, S)$ até $c_{s+1} - 1$ do seletor, do menos significativo ao mais significativo, e cada palavra do nível $s+1$ escolhe uma entre $2^{c_{s+1}-c_s}$ palavras adjacentes do nível $s$. Quando $S$ não é múltiplo de $B$, o último estágio consome os bits restantes: com $S = 5$ e $B = 2$, os estágios consomem 2, 2 e 1 bit. A saída é a única palavra do último nível.

$$L_{s+1}[j] = L_s\left[j \cdot 2^{c_{s+1}-c_s} + \mathrm{unsigned}\left(i\_sel[c_{s+1}-1 : c_s]\right)\right], \qquad 0 \le j < 2^{S-c_{s+1}}$$

$$o\_d = L_S[0] = i\_array[\mathrm{unsigned}(i\_sel)]$$

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, nas duas portas de leitura do banco de registradores, e `Zihpm/hpm_counter_bank.vhd`, na seleção do evento e das metades do contador lido |

## 5. Permanência no Common-Components

O bloco é usado apenas pelo Core. Por ser um multiplexador genérico, sem dependência de ISA nem de periférico, ele permanece no Common-Components (regra 7 da seção 5 do `CONTRIBUTING.md`). Outro repositório que precise de uma seleção de $N$ entradas importa este bloco pelo submódulo `src/common` e não escreve uma árvore própria.

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
