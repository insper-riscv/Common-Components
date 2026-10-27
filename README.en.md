# Common-Components

🌐 [Português](README.md) · [English](README.en.md)

Generic VHDL blocks that [Core](https://github.com/insper-riscv/Core), [Memory](https://github.com/insper-riscv/Memory), and [Peripherals](https://github.com/insper-riscv/Peripherals) share. Each block exists here exactly once, and the other repositories import it as a sibling (`../Common-Components`).

## 1. Documentation

- [CONTRIBUTING.en.md](CONTRIBUTING.en.md): mandatory contribution rules, VHDL-2008 standard, naming, headers, docstrings, and verification before opening a Pull Request.

## 2. Contents

| File | Block |
| :--- | :--- |
| `adder.vhd` | Parameterizable adder |
| `flip_flop.vhd` | 1-bit flip-flop with enable and asynchronous reset |
| `generic_register.vhd` | Parameterizable register with enable and asynchronous reset |
| `mux_2x1.vhd`, `mux_4x1.vhd`, `mux_tree.vhd` | 2-, 4-, and N-input multiplexers |
| `onehot_decoder.vhd` | One-hot decoder |
| `utils_pkg.vhd` | Helper types and functions |
| `clearable_register.vhd` | Parallel register with synchronous clear and enable, built on `generic_register` |
| `tristate_buffer_1bit.vhd` | 1-bit tri-state buffer |

## 3. Verification

```bash
make check   # VHDL syntax check of every source, in dependency order (GHDL)
```

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](LICENSE).
