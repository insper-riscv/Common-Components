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

## 3. Running

```bash
make formal                          # default engine (bitwuzla)
make formal FORMAL_ENGINE=yices      # another engine
```

`abc-bmc3` skips the induction proofs and the covers, which it does not do, and answers only for the mutants.

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
