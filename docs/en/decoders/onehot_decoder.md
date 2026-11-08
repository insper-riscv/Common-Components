# onehot_decoder

🌐 [Português](../../pt-br/decoders/onehot_decoder.md) · [English](../../en/decoders/onehot_decoder.md)

## 1. Purpose

Decoder from a binary index of $N$ bits to a one-hot vector of $2^{N}$ bits, where $N$ is the `num_inputs` generic.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `num_inputs` | `natural` | `3` | Width of the binary input index, in bits. The name is historical, since the value is a width and not an input count. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_d` | in | `std_logic_vector(num_inputs-1 downto 0)` | Binary index. |
| `o_d` | out | `std_logic_vector(2**num_inputs-1 downto 0)` | One-hot vector. |

## 4. Behavior

Each output bit is an AND of $N$ literals of `i_d`, direct for the bits where index $k$ is 1 and inverted for the others.

$$o\_d[k] = \bigwedge_{j=0}^{N-1} \begin{cases} i\_d[j] & k_j = 1 \\ \overline{i\_d[j]} & k_j = 0 \end{cases}$$

Bit $k_j$ is bit $j$ of $k$ in binary. As a consequence, $o\_d[k] = 1$ if and only if $\mathrm{unsigned}(i\_d) = k$.

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, which decodes the destination register to enable the write |

## 5. Placement in Common-Components

The block is used only by the Core. Being a generic decoder with no dependency on the ISA, it stays in Common-Components (rule 7 of section 5 of `CONTRIBUTING.md`). A repository that needs a one-hot decoder imports it through the `src/common` submodule.

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
