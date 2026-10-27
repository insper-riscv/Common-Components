# Common-Components

🌐 [Português](README.md) · [English](README.en.md)

Blocos genéricos de VHDL que o [Core](https://github.com/insper-riscv/Core), a [Memory](https://github.com/insper-riscv/Memory) e os [Peripherals](https://github.com/insper-riscv/Peripherals) compartilham. Cada bloco existe aqui uma só vez, e os demais repositórios o importam como irmão (`../Common-Components`).

## 1. Conteúdo

| Arquivo | Bloco |
| :--- | :--- |
| `adder.vhd` | Somador parametrizável |
| `flip_flop.vhd` | Flip-flop de 1 bit com habilitação e reset assíncrono |
| `generic_register.vhd` | Registrador parametrizável com habilitação e reset assíncrono |
| `mux_2x1.vhd`, `mux_4x1.vhd`, `mux_tree.vhd` | Multiplexadores de 2, 4 e N entradas |
| `onehot_decoder.vhd` | Decodificador one-hot |
| `utils_pkg.vhd` | Tipos e funções auxiliares |
| `GENERICS.vhd`, `GENERIC_FLIP_FLOP.vhd` | Pacote de tipos e flip-flop de 1 bit com clear síncrono |
| `GENERIC_MUX_4X1.vhd`, `GENERIC_MUX_8X1.vhd` | Multiplexadores de 4 e 8 entradas dos periféricos |
| `TRISTATE_BUFFER_1BIT.vhd` | Buffer de três estados de 1 bit |

## 2. Verificação

```bash
make check   # verificação de sintaxe VHDL de todos os fontes, em ordem de dependência (GHDL)
```

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](LICENSE).
