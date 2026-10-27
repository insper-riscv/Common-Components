# Authors

🌐 [Português](AUTHORS.md) · [English](AUTHORS.en.md)

This repository is part of the Computer Engineering and Computer Science Capstone at [Insper](https://www.insper.edu.br), led by Professor **Rafael Corsi Ferrão** ([@rafaelcorsi](https://github.com/rafaelcorsi)) and funded by [CTI Renato Archer](https://www.gov.br/cti/pt-br). The list below gathers the people who wrote the blocks that `Common-Components` brings together, according to the commit history of the source repositories (`RV32` before the split, `Core`, and `Peripherals`).

## 1. Authors of this Module

| Period | Name | GitHub account | Source blocks |
| :--- | :--- | :--- | :--- |
| 2026.2 | Lucas Hix | [@Peng1104](https://github.com/Peng1104) | `mux_tree`, `onehot_decoder`, and the `equals`, `not_equals`, and `log2_ceil` functions of `utils_pkg`; the reorganization of every block (`snake_case` names and `i_` and `o_` ports); the current `mux_4x1`, the `mux_8x1`, the `clearable_register`, and the `tristate_buffer_1bit`; the tests and continuous integration |
| 2025.2 | Ilana Chaia Finger | [@ilacftemp](https://github.com/ilacftemp) | the generic 2- and 4-input multiplexers (`muxGenerico2x1` and `muxGenerico4x1`), from which `mux_2x1` and `mux_4x1` come, and the first version of the generic register, from which `generic_register` comes |
| 2025.2 | Lucas Fernando De Souza Lima | [@lucasouzamil](https://github.com/lucasouzamil) | the generic adder (`genericAdder` and `genericAdderU`, origin of `adder`), the flip-flop (`FlipFlop`, origin of `flip_flop`), the generic multiplexer (`genericMux2x1`), and the timer's register with synchronous clear, from which `clearable_register` comes |
| 2025.2 | Leonardo Merlin Paloschi | [@leonardopaloschi](https://github.com/leonardopaloschi) | the 8-input multiplexer (`GENERIC_MUX_8X1`, origin of `mux_8x1`), the tri-state buffer (`TRISTATE_BUFFER_1BIT`, origin of `tristate_buffer_1bit`), the flip-flop with synchronous clear (`GENERIC_FLIP_FLOP`), and the `GENERICS` package, from which `reverse_vector`, `reduce_or`, `reduce_and`, and `is_equal_dynamic` of `utils_pkg` come |

## 2. Project History

Each Capstone group continued the work of the previous one. The complete list of groups, including those without commits in the blocks of this repository, is in the [organization README](https://github.com/insper-riscv/.github/blob/main/profile/README.md).

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](LICENSE).
