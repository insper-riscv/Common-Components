# onehot_decoder

🌐 [Português](../../pt-br/decoders/onehot_decoder.md) · [English](../../en/decoders/onehot_decoder.md)

## 1. Finalidade

Decodificador de um índice binário de $N$ bits para um vetor one-hot de $2^{N}$ bits, com $N$ igual ao genérico `num_inputs`.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `num_inputs` | `natural` | `3` | Largura do índice binário de entrada, em bits. O nome é histórico, pois o valor é uma largura e não uma contagem de entradas. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_d` | in | `std_logic_vector(num_inputs-1 downto 0)` | Índice binário. |
| `o_d` | out | `std_logic_vector(2**num_inputs-1 downto 0)` | Vetor one-hot. |

## 4. Comportamento

Cada bit de saída é um E de $N$ literais de `i_d`, direto para os bits em que o índice $k$ vale 1 e invertido para os demais.

$$o\_d[k] = \bigwedge_{j=0}^{N-1} \begin{cases} i\_d[j] & k_j = 1 \\ \overline{i\_d[j]} & k_j = 0 \end{cases}$$

O bit $k_j$ é o bit $j$ de $k$ em binário. Em consequência, $o\_d[k] = 1$ se e somente se $\mathrm{unsigned}(i\_d) = k$.

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, que decodifica o registrador de destino para habilitar a escrita |

## 5. Permanência no Common-Components

O bloco é usado apenas pelo Core. Por ser um decodificador genérico, sem dependência de ISA, ele permanece no Common-Components (regra 7 da seção 5 do `CONTRIBUTING.md`). Outro repositório que precise de um decodificador one-hot o importa pelo submódulo `src/common`.

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
