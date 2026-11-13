# Common-Components

🌐 [Português](README.md) · [English](README.en.md)

Generic VHDL blocks that [Core](https://github.com/insper-riscv/Core), [Memory](https://github.com/insper-riscv/Memory), and [Peripherals](https://github.com/insper-riscv/Peripherals) share. Each block exists here exactly once, and the other repositories import it as a submodule (`Common-Components`).

## 1. Documentation

- [docs/en](docs/en/README.md): one page per entity and package in `src/`, with purpose, generics, ports, behavior and points of use; the Portuguese mirror is in `docs/pt-br`.
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
| `mux_2x1.vhd`, `mux_4x1.vhd`, `mux_8x1.vhd`, `mux_16x1.vhd`, `mux_32x1.vhd`, `mux_64x1.vhd`, `mux_tree.vhd` | 2-, 4-, 8-, 16-, 32-, 64-, and N-input multiplexers |
| `onehot_decoder.vhd` | One-hot decoder |
| `tristate_buffer_1bit.vhd` | 1-bit tri-state buffer |
| `synchronizer.vhd` | Clock-domain-crossing synchronizer, with `stages` flip-flops in series and `data_width` independent bits |
| `altera/virtual_jtag.vhd` | Intel Virtual JTAG (`sld_virtual_jtag`) with the instance index and IR width as generics, FPGA only (needs the `altera_mf` library) |
| `config_pkg.vhd` | Package of elaboration constants that mirrors `platform.yaml`: ISA base (`IS_64`, `IS_E`), address width (`ADDR_BITS`), the subtypes `word_t`, `reg_t`, `addr_t` and `map_addr_t`, one `HAS_*` constant per extension, cache and peripheral, the memory map in bytes and the functions `isa_string` and `check_isa`. A platform top swaps the file for a generated version with the same name |
| `counter64.vhd` | Counter of up to 64 bits in two halves, with registered carry, per-half write and an overflow pulse; the word width comes from `config_pkg` |
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

Each block has an entity test in `tests/python/unittests/`, and the catalog that drives them is `tests/python/tests.json`. The test wrappers in `tests/vhdl/` flatten the types that cocotb cannot see (`mux_tree`, `utils_pkg`, `config_pkg`). The tools (GHDL and uv) come from the `ci-vhdl` image of the [Infra](https://github.com/insper-riscv/Infra) repository, where continuous integration runs.

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](LICENSE).
