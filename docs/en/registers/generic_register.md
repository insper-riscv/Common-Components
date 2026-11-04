# generic_register

🌐 [Português](../../pt-br/registers/generic_register.md) · [English](../../en/registers/generic_register.md)

## 1. Purpose

Parallel register of configurable width with load enable and an asynchronous reset that clears every bit.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Register width, in bits. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_d` | in | `std_logic_vector(data_width-1 downto 0)` | Data to store. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Stored data. Initial value zero. |
| `i_enable` | in | `std_logic` | Enables loading on the rising edge. |
| `i_clk` | in | `std_logic` | Clock, rising-edge sensitive. |
| `i_rst` | in | `std_logic` | Asynchronous reset, active at `'1'`. |

## 4. Behavior

Reset has priority over the clock. Outside reset, loading only happens on the rising edge of `i_clk` with `i_enable` at `'1'`.

$$o\_d^{+} = \begin{cases} 0 & i\_rst = 1 \\ i\_d & i\_rst = 0 \wedge \uparrow i\_clk \wedge i\_enable = 1 \\ o\_d & \text{otherwise} \end{cases}$$

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, `shared/pc_fetch.vhd`, `Zicclsm/misaligned_unit.vhd`, `core/core.vhd`, `Zicntr/counter64.vhd`, `M/muldiv_fusion.vhd`, `M/multdiv.vhd`, `Zicsr/csr_file.vhd` |
| Common-Components | `clearable_register.vhd`, which instantiates it internally |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
