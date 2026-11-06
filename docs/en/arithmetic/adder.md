# adder

🌐 [Português](../../pt-br/arithmetic/adder.md) · [English](../../en/arithmetic/adder.md)

## 1. Purpose

Combinational unsigned adder of two operands of equal width. The sum is truncated to the operand width, so the final carry is discarded.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `32` | Width of the operands and of the output, in bits. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_a` | in | `std_logic_vector(data_width-1 downto 0)` | First operand. |
| `i_b` | in | `std_logic_vector(data_width-1 downto 0)` | Second operand. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Sum of the operands. |

## 4. Behavior

The result is the sum modulo $2^{W}$, where $W$ is the `data_width` generic.

$$o\_d = (i\_a + i\_b) \bmod 2^{W}$$

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `shared/pc_fetch.vhd`, `core/stage_ex.vhd`, `M/multdiv.vhd` |
| Peripherals | `TIMER/soc/clock_prescaler.vhd`, `TIMER/soc/timer.vhd` |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
