# Formal verification

🌐 [Português](../../pt-br/formal/formal.md) · [English](../../en/formal/formal.md)

The formal proofs run in SymbiYosys on the Verilog netlist that GHDL synthesizes from each entity, with the properties written in SystemVerilog around it (`formal/<entity>_props.sv`). The method, the engines (`yices`, `bitwuzla`, `boolector` and `abc-bmc3`), the `build/formal/result-<engine>.tsv` file and the rule of the `formal/aggregate.sh` aggregator are the Core's. This document describes what is proved on the primitives of this repository.

## 1. What is proved

| Entity | File | Variants proved | Properties |
| :--- | :--- | :--- | :--- |
| `synchronizer` | `synchronizer_props.sv` | 2 stages with 2 bits, 3 stages with 1 bit | With `stages` edges without reset, the output is the input from `stages` edges ago, for every input sequence; after a reset the output stays at zero until the first sample reaches the last stage |
| `flip_flop` | `flip_flop_props.sv` | single | The asynchronous reset clears the output in the same cycle and beats the enable; with enable the edge loads `i_d`; without enable the value is kept |
| `generic_register` | `generic_register_props.sv` | 4 bits | The same properties as `flip_flop`, for the whole vector |
| `clearable_register` | `clearable_register_props.sv` | `clear_value` at `'0'` and at `'1'` | The clear beats the enable and loads the clear value in every bit; with enable and without clear the edge loads `i_d`; with neither the value is kept |
| `config_pkg` | `config_pkg_props.sv` | default (RV32IM, 32 bits), `IS_64` with `ADDR_BITS` 40 and the E base, swapping the `config_pkg.vhd` of the source list | The relations between `XLEN`, `NUM_REGS`, `REG_BITS` and `ADDR_BITS`, the length of the subtypes, the increasing map within $2^{ADDR\_BITS}$, the ISA name and the acceptance by `check_isa`; seven invalid configurations are rejected with `assertion failure` in the synthesis |
| `counter64` | `counter64_props.sv` | widths 1, 20, 32, 33, 63 and 64 with the 32-bit word, and 1, 33 and 64 with the 64-bit word | The pair of halves is always the ideal value, a write wins over the increment, the carry is never lost, `o_wrap` is the ideal overflow and the value does not decrease without a write |

The properties of the `synchronizer` stages hold by induction, and each entity has a cover that shows the proved situation is reachable (a sample reaches the output, a reset empties the chain, a clear happens together with an enable).

## 2. Mutants

Each deliberate defect of the VHDL must make a proof fail. `formal/run.sh` applies each edit with `sed` to a copy of the file and requires the `fail` verdict.

| Mutant | Defect | Property that catches it |
| :--- | :--- | :--- |
| `sync_short_chain` | output one stage before the last | latency of `stages` edges |
| `sync_long_chain` | output straight from the first stage | latency of `stages` edges |
| `sync_reset_ignored` | synchronous reset ignored | output at zero after the reset |
| `sync_reset_stage0_only` | reset clears only the first stage | output at zero after the reset |
| `ff_enable_ignored` | always loads | value kept without enable |
| `ff_no_async_reset` | reset only on the clock edge | asynchronous reset in the same cycle |
| `ff_reset_to_one` | reset goes to `'1'` | output zero on reset |
| `reg_enable_ignored` | always loads | value kept without enable |
| `reg_reset_one_bit` | reset leaves one bit at `'1'` | output zero on reset |
| `reg_no_hold` | loads `not i_d` | loaded value equals `i_d` |
| `clr_enable_wins` | enable beats the clear | clear priority |
| `clr_no_clear` | clear without a load | clear loads the clear value |
| `clr_wrong_value` | clear always to zeros | clear value `'1'` |
| `carry_lost` | carry only when the top bit of the low half is one | carry of the full low half |
| `width_one_bit_wider` | high half one bit wider | bits above the width read zero |
| `write_adds_one` | the write adds one to the value | written value equal to `i_wdata` |
| `no_increment_idle` | increment only with a write | one addition per enabled cycle |
| `wrap_without_hi` | overflow without checking the full high half | `o_wrap` only on overflow of the whole counter |
| `wrap_on_lo_write` | a write to the low half raises an overflow | `o_wrap` never by a write |

## 3. Running

```bash
make formal                          # default engine (bitwuzla)
make formal FORMAL_ENGINE=yices      # another engine
```

`abc-bmc3` skips the induction proofs and the covers, which it does not do, and answers only for the mutants.

## 4. A warning is an error

Any warning from GHDL, Yosys or SymbiYosys makes `formal/run.sh` fail, in the proofs and in the mutants. The script scans the output of each tool after it ends and, for every line with the word `warning` (case-insensitive, whole word or plural), prints `formal: WARNING treated as error: <file>:<line>:<text>`. Names such as `warning_count` and the Yosys summary `Warnings: 0` do not count.

A warning means code outside the norm or at its limit, so the fix is in the VHDL or in the properties, never in an option that hides the warning (`-Wno-*`). Besides the proofs, the synthesis of `mux_tree`, which has no proof, goes through the same scan.

The `altera_attribute` of the `synchronizer` only annotates the signal for Quartus and GHDL does not know it, so the copy that enters the formal netlist is without it.

The `abc-bmc3` engine has one exact exception, only for the three messages that ABC itself prints about the AIGER file it receives (the clock consumed by the `clk2ff` step, and the count of outputs read as constraints). They describe neither the design nor the properties, and any other warning of that engine still fails.

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
