# Common-Components

🌐 [Português](README.md) · [English](README.en.md)

Blocos genéricos de VHDL que o [Core](https://github.com/insper-riscv/Core), a [Memory](https://github.com/insper-riscv/Memory) e os [Peripherals](https://github.com/insper-riscv/Peripherals) compartilham. Cada bloco existe aqui uma só vez, e os demais repositórios o importam como irmão (`../Common-Components`).

## 1. Documentação

- [AUTHORS.md](AUTHORS.md): autores com commits no repositório, com nome e conta do GitHub.
- [CONTRIBUTING.md](CONTRIBUTING.md): regras obrigatórias de contribuição, norma VHDL-2008, nomenclatura, cabeçalhos, docstrings e verificação antes de abrir Pull Request.
- [CITATION.cff](CITATION.cff): metadados para citação do software.

## 2. Conteúdo

| Arquivo | Bloco |
| :--- | :--- |
| `adder.vhd` | Somador parametrizável |
| `flip_flop.vhd` | Flip-flop de 1 bit com habilitação e reset assíncrono |
| `generic_register.vhd` | Registrador parametrizável com habilitação e reset assíncrono |
| `mux_2x1.vhd`, `mux_4x1.vhd`, `mux_tree.vhd` | Multiplexadores de 2, 4 e N entradas |
| `onehot_decoder.vhd` | Decodificador one-hot |
| `utils_pkg.vhd` | Tipos e funções auxiliares |
| `clearable_register.vhd` | Registrador paralelo com clear síncrono e habilitação, composto sobre o `generic_register` |
| `tristate_buffer_1bit.vhd` | Buffer de três estados de 1 bit |

## 3. Verificação

```bash
make check   # verificação de sintaxe VHDL de todos os fontes, em ordem de dependência (GHDL)
```

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](LICENSE).
