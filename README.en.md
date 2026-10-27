# Common-Components

🌐 [Português](README.md) · [English](README.en.md)

Generic VHDL blocks that [Core](https://github.com/insper-riscv/Core), [Memory](https://github.com/insper-riscv/Memory), and [Peripherals](https://github.com/insper-riscv/Peripherals) share. Each block exists here exactly once, and the other repositories import it as a submodule (`Common-Components`).

## 1. Documentation

- [AUTHORS.en.md](AUTHORS.en.md): authors with commits in the repository, with name and GitHub account.
- [CONTRIBUTING.en.md](CONTRIBUTING.en.md): mandatory contribution rules, VHDL-2008 standard, naming, headers, docstrings, and verification before opening a Pull Request.
- [CITATION.cff](CITATION.cff): metadata for citing the software.

## 2. Contents

The sources are in `src/`.

| File | Block |
| :--- | :--- |
| `adder.vhd` | Parameterizable adder |
| `flip_flop.vhd` | 1-bit flip-flop with enable and asynchronous reset |
| `generic_register.vhd` | Parameterizable register with enable and asynchronous reset |
| `clearable_register.vhd` | Parallel register with synchronous clear and enable, built on `generic_register` |
| `mux_2x1.vhd`, `mux_4x1.vhd`, `mux_8x1.vhd`, `mux_tree.vhd` | 2-, 4-, 8-, and N-input multiplexers |
| `onehot_decoder.vhd` | One-hot decoder |
| `tristate_buffer_1bit.vhd` | 1-bit tri-state buffer |
| `utils_pkg.vhd` | Helper types and functions: vector comparison (`equals`, `not_equals`, `is_equal_dynamic`), bit reversal (`reverse_vector`), tree OR and AND reduction (`reduce_or`, `reduce_and`), and `log2_ceil` |

## 3. Verification

```bash
git clone --recurse-submodules https://github.com/insper-riscv/Common-Components.git
cd Common-Components
uv sync

make check   # VHDL-2008 syntax check of every source, in dependency order (GHDL)
make test    # Per-entity cocotb tests (make test TEST=Adder for one target)
make paths   # Existence of every path listed in the configuration
```

Each block has an entity test in `tests/python/unittests/`, and the catalog that drives them is `tests/python/tests.json`. The test wrappers in `tests/vhdl/` flatten the types that cocotb cannot see (`mux_tree`, `utils_pkg`). The tools (GHDL and uv) come from the `ci-vhdl` image of the [Infra](https://github.com/insper-riscv/Infra) repository, where continuous integration runs.

--- | :--- |
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
