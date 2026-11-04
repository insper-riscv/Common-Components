# tristate_buffer_1bit

🌐 [Português](../../pt-br/io/tristate_buffer_1bit.md) · [English](../../en/io/tristate_buffer_1bit.md)

## 1. Purpose

One-bit tri-state buffer, which lets several drivers share a single pin or bidirectional bus.

## 2. Generics

The entity has no generics.

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_d` | in | `std_logic` | Data driven when the buffer is enabled. |
| `i_enable` | in | `std_logic` | Driver enable. |
| `o_d` | out | `std_logic` | Tri-state output. |

## 4. Behavior

$$o\_d = \begin{cases} i\_d & i\_enable = 1 \\ \text{Z} & \text{otherwise} \end{cases}$$

The symbol Z denotes high impedance.

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Peripherals | `TIMER/soc/timer.vhd`, `GPIO/soc/gpio_cell.vhd` |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
