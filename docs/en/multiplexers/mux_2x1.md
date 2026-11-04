# mux_2x1

🌐 [Português](../../pt-br/multiplexers/mux_2x1.md) · [English](../../en/multiplexers/mux_2x1.md)

## 1. Purpose

Combinational multiplexer with two inputs of equal width.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Width of each bus, in bits. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_d0` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 0. |
| `i_d1` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 1. |
| `i_sel` | in | `std_logic` | Selector of the input that reaches the output. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Selected input. |

## 4. Behavior

$$o\_d = \begin{cases} i\_d0 & i\_sel = 0 \\ i\_d1 & i\_sel = 1 \end{cases}$$

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, `core/core.vhd`, `core/stage_ex.vhd`, `core/stage_wb.vhd`, `M/multdiv.vhd` |
| Peripherals | `TIMER/soc/timer.vhd` |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
