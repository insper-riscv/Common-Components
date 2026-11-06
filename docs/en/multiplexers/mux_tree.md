# mux_tree

🌐 [Português](../../pt-br/multiplexers/mux_tree.md) · [English](../../en/multiplexers/mux_tree.md)

## 1. Purpose

Multiplexer with $2^{S}$ inputs organized as a balanced binary tree of $S$ stages, where $S$ is the `selector_width` generic. Stage $i$ is controlled by bit $i$ of the selector.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Width of each word, in bits. |
| `selector_width` | `natural` | `5` | Selector width, in bits. The number of input words is $2^{S}$. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_array` | in | `word_array_t(2**selector_width-1 downto 0)(data_width-1 downto 0)` | Array of input words, type defined in `utils_pkg`. |
| `i_sel` | in | `std_logic_vector(selector_width-1 downto 0)` | Binary index of the chosen word. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Selected word. |

## 4. Behavior

Level 0 receives the input array. Each level $i+1$ has half the words of level $i$ and chooses between two adjacent words by bit $i$ of the selector. The output is the single word of the last level.

$$L_{i+1}[j] = \begin{cases} L_i[2j+1] & i\_sel[i] = 1 \\ L_i[2j] & i\_sel[i] = 0 \end{cases}, \qquad 0 \le j < 2^{S-i-1}$$

$$o\_d = L_S[0] = i\_array[\mathrm{unsigned}(i\_sel)]$$

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, in both read ports of the register file, and `Zihpm/hpm_counter_bank.vhd`, in the selection of the event and of the halves of the counter read |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
