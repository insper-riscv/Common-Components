# flip_flop

🌐 [Português](../../pt-br/registers/flip_flop.md) · [English](../../en/registers/flip_flop.md)

## 1. Purpose

One-bit D flip-flop with load enable and asynchronous reset.

## 2. Generics

The entity has no generics.

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_d` | in | `std_logic` | Bit to store. Default value `'0'`. |
| `o_d` | out | `std_logic` | Stored bit. Initial value `'0'`. |
| `i_enable` | in | `std_logic` | Enables loading on the rising edge. Default value `'0'`. |
| `i_clk` | in | `std_logic` | Clock, rising-edge sensitive. |
| `i_rst` | in | `std_logic` | Asynchronous reset, active at `'1'`. Default value `'1'`, so an unconnected port keeps the bit at zero. |

## 4. Behavior

Reset has priority over the clock. Outside reset, loading only happens on the rising edge of `i_clk` with `i_enable` at `'1'`.

$$o\_d^{+} = \begin{cases} 0 & i\_rst = 1 \\ i\_d & i\_rst = 0 \wedge \uparrow i\_clk \wedge i\_enable = 1 \\ o\_d & \text{otherwise} \end{cases}$$

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `Zicclsm/misaligned_unit.vhd`, `Zifencei/fencei_unit.vhd`, `core/core.vhd`, `Zicsr/csr_file.vhd`, `Zicntr/counter64.vhd`, `M/multdiv.vhd`, `M/muldiv_fusion.vhd` |
| Peripherals | `TIMER/soc/clock_prescaler.vhd`, `TIMER/soc/timer.vhd`, `GPIO/soc/gpio_cell.vhd`, `CLINT/soc/clint.vhd`, `CLINT/soc/clint_mtime.vhd` |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
