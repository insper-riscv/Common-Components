# clearable_register

🌐 [Português](../../pt-br/registers/clearable_register.md) · [English](../../en/registers/clearable_register.md)

## 1. Purpose

Parallel register with synchronous clear and load enable, without asynchronous reset. It is built on the `generic_register`, whose reset input is tied to `'0'`.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `32` | Register width, in bits. |
| `clear_value` | `std_logic` | `'0'` | Value each bit takes on clear. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_clk` | in | `std_logic` | Clock, rising-edge sensitive. |
| `i_clear` | in | `std_logic` | Synchronous clear, with priority over `i_enable`. |
| `i_enable` | in | `std_logic` | Enables loading `i_d`. |
| `i_d` | in | `std_logic_vector(data_width-1 downto 0)` | Data to store. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Stored value. |

## 4. Behavior

On the rising edge of `i_clk` the priority below applies, with $C$ equal to the `data_width`-bit vector that repeats `clear_value`.

$$o\_d^{+} = \begin{cases} C & i\_clear = 1 \\ i\_d & i\_clear = 0 \wedge i\_enable = 1 \\ o\_d & \text{otherwise} \end{cases}$$

The inner entity receives enable $i\_clear \vee i\_enable$ and data $C$ on clear, or `i_d` otherwise.

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Peripherals | `TIMER/soc/clock_prescaler.vhd`, `TIMER/soc/timer.vhd`, `GPIO/soc/gpio_cell.vhd`, `CLINT/soc/clint.vhd` |

## 5. Placement in Common-Components

The block is used only by the Peripherals. Being a generic register with clear and no dependency on a peripheral, it stays in Common-Components with the other registers (rule 7 of section 5 of `CONTRIBUTING.md`). A repository that needs a register with clear imports it through the `src/common` submodule.

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
