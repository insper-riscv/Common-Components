# mux_2x1

🌐 [Português](../../pt-br/multiplexers/mux_2x1.md) · [English](../../en/multiplexers/mux_2x1.md)

## 1. Finalidade

Multiplexador combinacional de duas entradas de mesma largura.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Largura de cada barramento, em bits. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_d0` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 0. |
| `i_d1` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 1. |
| `i_sel` | in | `std_logic` | Seletor da entrada que chega à saída. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada. |

## 4. Comportamento

$$o\_d = \begin{cases} i\_d0 & i\_sel = 0 \\ i\_d1 & i\_sel = 1 \end{cases}$$

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, `core/core.vhd`, `core/stage_ex.vhd`, `core/stage_wb.vhd`, `M/multdiv.vhd` |
| Peripherals | `TIMER/soc/timer.vhd` |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
