# mux_tree

🌐 [Português](../../pt-br/multiplexers/mux_tree.md) · [English](../../en/multiplexers/mux_tree.md)

## 1. Finalidade

Multiplexador de $2^{S}$ entradas organizado como árvore binária balanceada de $S$ estágios, com $S$ igual ao genérico `selector_width`. O estágio $i$ é controlado pelo bit $i$ do seletor.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Largura de cada palavra, em bits. |
| `selector_width` | `natural` | `5` | Largura do seletor, em bits. O número de palavras de entrada é $2^{S}$. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_array` | in | `word_array_t(2**selector_width-1 downto 0)(data_width-1 downto 0)` | Matriz de palavras de entrada, tipo definido no `utils_pkg`. |
| `i_sel` | in | `std_logic_vector(selector_width-1 downto 0)` | Índice binário da palavra escolhida. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Palavra selecionada. |

## 4. Comportamento

O nível 0 recebe a matriz de entrada. Cada nível $i+1$ tem metade das palavras do nível $i$ e escolhe entre duas palavras adjacentes pelo bit $i$ do seletor. A saída é a única palavra do último nível.

$$L_{i+1}[j] = \begin{cases} L_i[2j+1] & i\_sel[i] = 1 \\ L_i[2j] & i\_sel[i] = 0 \end{cases}, \qquad 0 \le j < 2^{S-i-1}$$

$$o\_d = L_S[0] = i\_array[\mathrm{unsigned}(i\_sel)]$$

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, nas duas portas de leitura do banco de registradores, e `Zihpm/hpm_counter_bank.vhd`, na seleção do evento e das metades do contador lido |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
