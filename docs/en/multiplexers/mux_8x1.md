# mux_8x1

🌐 [Português](../../pt-br/multiplexers/mux_8x1.md) · [English](../../en/multiplexers/mux_8x1.md)

## 1. Purpose

Combinational multiplexer with eight inputs of equal width.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Width of each bus, in bits. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_d0` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 0. |
| `i_d1` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 1. |
| `i_d2` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 2. |
| `i_d3` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 3. |
| `i_d4` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 4. |
| `i_d5` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 5. |
| `i_d6` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 6. |
| `i_d7` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 7. |
| `i_sel` | in | `std_logic_vector(2 downto 0)` | Selector of the input that reaches the output. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Selected input. |

## 4. Behavior

With $k$ the numeric value of `i_sel`, the output is the input of index $k$.

$$o\_d = i\_d_k, \quad k = \mathrm{unsigned}(i\_sel) \in \{0, 1, \dots, 7\}$$

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Peripherals | `TIMER/soc/timer.vhd`, `GPIO/soc/gpio.vhd` |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
