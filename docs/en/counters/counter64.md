# counter64

🌐 [Português](../../pt-br/counters/counter64.md) · [English](../../en/counters/counter64.md)

## 1. Purpose

Counter of up to 64 bits stored in two halves, with a registered carry. The low half holds the $\min(width, XLEN)$ low bits and the high half the remaining $width - XLEN$, absent when the counter fits in the low half. The word width $XLEN$ comes from [config_pkg](../packages/config_pkg.md), so on RV32 each half has up to 32 bits and on RV64 a 64-bit counter fits entirely in the low half. No 64-bit addition enters a combinational path.

## 2. Generics

| Generic | Type | Default | Range | Description |
| :--- | :--- | :--- | :--- | :--- |
| `width` | `positive` | 64 | 1 to 64 | Counter width, in bits |

## 3. Ports

### 3.1. Control

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_clk` | in | `std_logic` | Clock, rising-edge sensitive |
| `i_rst` | in | `std_logic` | Reset, active at `'1'`, which clears both halves and the carry |
| `i_inc` | in | `std_logic` | Adds 1 to the counter in this cycle when `'1'` |

### 3.2. Write

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_we_lo` | in | `std_logic` | Writes the low half with `i_wdata` when `'1'` |
| `i_we_hi` | in | `std_logic` | Writes the high half with `i_wdata` when `'1'` |
| `i_wdata` | in | `word_t` | Value written to the selected half |

### 3.3. Read

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `o_lo` | out | `word_t` | Low half of the counter |
| `o_hi` | out | `word_t` | High half, with the pending carry already added |
| `o_wrap` | out | `std_logic` | One-cycle pulse when an addition takes the whole counter from all ones to zero |

## 4. Behavior

| Aspect | Behavior |
| :--- | :--- |
| Increment | The low half adds 1 in the cycles with `i_inc` at `'1'` |
| Carry | When the low half was all ones, the carry is registered and the high half adds 1 in the next cycle |
| Read | The high half read already includes the pending carry, so the pair $(o\_hi, o\_lo)$ is always the ideal counter value |
| Write to the low half | Replaces the value and cancels the increment and the carry of the same cycle |
| Write to the high half | Replaces the value and drops the pending carry |
| Width | The bits of each output above the width of the half read zero, and a write keeps only the bits that fit |
| Overflow | `o_wrap` pulses when an addition, never a write, takes the whole counter to zero |

A write wins over the increment of its own cycle, in each half. In a counter that fits in the low half, `o_wrap` is registered, one cycle after the addition. In a counter with a high half, `o_wrap` holds in the cycle when the pending carry takes the high half from all ones to zero, which is the cycle after the addition.

$$value = o\_hi \cdot 2^{XLEN} + o\_lo$$

## 5. Verification

| Proof | File | What it guarantees |
| :--- | :--- | :--- |
| `counter64` | `formal/counter64_props.sv` | The pair of halves is always the ideal value, a write wins over the increment, the carry is never lost, `o_wrap` is the ideal overflow and the value does not decrease without a write (induction, cover), at widths 1, 20, 32, 33, 63 and 64 and with the 32-bit and the 64-bit word |

## 6. Where it is used

| Repository | Files |
| :--- | :--- |
| Core | `Zicsr/csr_file.vhd` (`mcycle`, `minstret`, `time`) and `Zihpm/hpm_counter_bank.vhd` (event counters) |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
