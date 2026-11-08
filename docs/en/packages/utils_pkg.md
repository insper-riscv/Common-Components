# utils_pkg

🌐 [Português](../../pt-br/packages/utils_pkg.md) · [English](../../en/packages/utils_pkg.md)

## 1. Purpose

Package of auxiliary types and combinational functions, resolved at elaboration time or as stateless logic.

## 2. Declarations

| Declaration | Kind | Description |
| :--- | :--- | :--- |
| `word_array_t` | type | Unconstrained array of `std_logic_vector`, used as a set of words. |
| `equals(a, b)` | function | Returns `'1'` when `a` and `b` are equal bit by bit. |
| `not_equals(a, b)` | function | Returns `'1'` when `a` and `b` differ in at least one bit. |
| `is_equal_dynamic(l, r)` | function | Bit-by-bit equality through a tree AND reduction. |
| `reverse_vector(l)` | function | Returns `l` with the bit order reversed. |
| `reduce_or(l)` | function | Tree OR reduction, with depth $O(\log n)$. |
| `reduce_and(l)` | function | Tree AND reduction, with depth $O(\log n)$. |
| `log2_ceil(arg)` | function | Smallest natural $n$ with $2^{n} \ge arg$. |
| `is_power_of_two(arg)` | function | True when `arg` is a power of two. Zero is not. |
| `log2_exact(arg)` | function | Returns $n$ with $2^{n} = arg$ and aborts elaboration with `severity failure` when `arg` is not a power of two. |
| `to_sl(b)` | function | Converts the boolean condition `b` to `std_logic`: `'1'` when true and `'0'` when false. |

## 3. Behavior

The vectors of `equals` and `not_equals` are read position by position from the least significant bit and must have the same width.

$$\mathrm{equals}(a, b) = \bigwedge_{i} (a_i \odot b_i), \qquad \mathrm{not\_equals}(a, b) = \bigvee_{i} (a_i \oplus b_i)$$

The `is_equal_dynamic` function computes $\mathrm{reduce\_and}(l \odot r)$. The reductions split the vector in half at $m = \lfloor (\mathrm{high} + \mathrm{low}) / 2 \rfloor$ and combine the two halves, which yields a tree with $\lceil \log_2 n \rceil$ gate levels instead of the linear chain of the IEEE library. A one-bit vector returns the bit itself.

The order reversal satisfies $\mathrm{result}[i] = l[\mathrm{high} + \mathrm{low} - i]$.

The width functions satisfy, for positive `arg`,

$$\mathrm{log2\_ceil}(arg) = \min \{ n \in \mathbb{N} \mid 2^{n} \ge arg \}, \qquad \mathrm{is\_power\_of\_two}(arg) \iff arg \ne 0 \wedge 2^{\mathrm{log2\_ceil}(arg)} = arg$$

and `log2_exact` returns $\mathrm{log2\_ceil}(arg)$ after checking the power-of-two condition. Thus `log2_ceil(1)` is 0 and `log2_exact(6)` fails.

The `to_sl` function returns `'1'` when the condition is true and `'0'` when it is false, which lets a comparison be used as a bit in a `std_logic` expression.

The `to_sl` function returns `'1'` when the condition is true and `'0'` when it is false, which lets a comparison be used as a bit in a `std_logic` expression.

## 4. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `word_array_t` in `shared/reg_file.vhd` and `Zihpm/hpm_counter_bank.vhd`; `equals` and `not_equals` in `shared/reg_file.vhd` (register file bypass); `log2_ceil` in `I-E/alu.vhd` (shift amount width) |
| Memory | `log2_exact` in `RAM/FPGA/Cyclone-V/ram.vhd`, `RAM/SoC/ram_chip.vhd`, `RAM/SoC/ram_simulation.vhd`, `RAM/SoC/onchip_ram_port.vhd`, `RAM/SoC/sim/onchip_ram_system.vhd`, `cache/SoC/icache.vhd`, `cache/SoC/dcache.vhd`, `cache/SoC/flash_chip.vhd`, `cache/SoC/flash_cmd_port.vhd`, `cache/SoC/sim/flash_dual_system.vhd`, `ROM/Cyclone-V/boot_memory.vhd`, `ROM/Cyclone-V/flash.vhd`, `ROM/Cyclone-V/flash_store.vhd`, `ROM/SoC/rom_simulation.vhd`, `ROM/SoC/flash_simulation.vhd`, `ROM/SoC/sim/flash_system.vhd`, `RAM/SoC/sram_ctrl.vhd`, `RAM/SoC/sim/sram_model.vhd`, `ROM/SoC/nor_flash_ctrl.vhd`, `ROM/SoC/sim/nor_flash_ctrl_tb.vhd` and `ROM/SoC/sim/nor_flash_model.vhd`; `word_array_t` in `RAM/SoC/ram_chip.vhd` |
| Peripherals | `log2_exact` in `flash-controller/soc/flash_controller.vhd` |
| Insper-RISC-V | `log2_exact` in `src/cyclone-v/de0-cv/de0-cv_top.vhd`, `src/cyclone-v/external-data/external-data_top.vhd`, `src/cyclone-v/external-data/external-data_sim_top.vhd`, `src/simulation/modular/modular_sim_top.vhd`, `src/simulation/internal-mem/quartus/core_fpga_test.vhd` and `src/simulation/template/rtl/template_sim_top.vhd` |
| Common-Components | `mux_tree.vhd`, which uses `word_array_t` |

## 5. Placement in Common-Components

The package is used by the Core, the Memory, the Peripherals and Insper-RISC-V. Being shared by all repositories, it stays in Common-Components, and none of them redefines a function with the same role (rule 7 of section 5 of `CONTRIBUTING.md`).

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
