# mux_tree

🌐 [Português](../../pt-br/multiplexers/mux_tree.md) · [English](../../en/multiplexers/mux_tree.md)

## 1. Purpose

Multiplexer with $2^{S}$ inputs organized as a balanced tree, where $S$ is the `selector_width` generic. Each stage consumes $B$ bits of the selector, where $B$ is the `stage_bits` generic, and chooses among $2^{B}$ adjacent words of the previous stage. With $B = 1$ the tree is binary, made of 2x1 stages; with $B = 2$, of 4x1 stages; with $B = 3$, of 8x1 stages. The block does not know the target device: `stage_bits` only chooses the structure, and the functional result is the same for any value.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Width of each word, in bits. |
| `selector_width` | `natural` | `5` | Selector width, in bits. The number of input words is $2^{S}$. |
| `stage_bits` | `positive` | `1` | Selector bits consumed per stage. A value greater than `selector_width` results in a single stage. Zero is rejected at elaboration. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_array` | in | `word_array_t(2**selector_width-1 downto 0)(data_width-1 downto 0)` | Array of input words, type defined in `utils_pkg`. |
| `i_sel` | in | `std_logic_vector(selector_width-1 downto 0)` | Binary index of the chosen word. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Selected word. |

## 4. Behavior

Level 0 receives the input array. The tree has $N = \lceil S / B \rceil$ stages. Stage $s$ consumes selector bits $c_s = \min(sB, S)$ up to $c_{s+1} - 1$, from the least to the most significant, and each word of level $s+1$ chooses one among $2^{c_{s+1}-c_s}$ adjacent words of level $s$. When $S$ is not a multiple of $B$, the last stage consumes the remaining bits: with $S = 5$ and $B = 2$, the stages consume 2, 2 and 1 bit. The output is the single word of the last level.

$$L_{s+1}[j] = L_s\left[j \cdot 2^{c_{s+1}-c_s} + \mathrm{unsigned}\left(i\_sel[c_{s+1}-1 : c_s]\right)\right], \qquad 0 \le j < 2^{S-c_{s+1}}$$

$$o\_d = L_S[0] = i\_array[\mathrm{unsigned}(i\_sel)]$$

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, in both read ports of the register file, and `Zihpm/hpm_counter_bank.vhd`, in the selection of the event and of the halves of the counter read |

## 5. Placement in Common-Components

The block is used only by the Core. Being a generic multiplexer with no dependency on the ISA or on a peripheral, it stays in Common-Components (rule 7 of section 5 of `CONTRIBUTING.md`). A repository that needs an $N$-input selection imports this block through the `src/common` submodule instead of writing its own tree.

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
