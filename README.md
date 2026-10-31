# Common-Components

🌐 [Português](README.md) · [English](README.en.md)

Blocos genéricos de VHDL que o [Core](https://github.com/insper-riscv/Core), a [Memory](https://github.com/insper-riscv/Memory) e os [Peripherals](https://github.com/insper-riscv/Peripherals) compartilham. Cada bloco existe aqui uma só vez, e os demais repositórios o importam como submódulo (`Common-Components`).

## 1. Documentação

- [AUTHORS.md](AUTHORS.md): autores com commits no repositório, com nome e conta do GitHub.
- [CONTRIBUTING.md](CONTRIBUTING.md): regras obrigatórias de contribuição, norma VHDL-2008, nomenclatura, cabeçalhos, docstrings e verificação antes de abrir Pull Request.
- [CITATION.cff](CITATION.cff): metadados para citação do software.

## 2. Conteúdo

Os fontes ficam em `src/`.

| Arquivo | Bloco |
| :--- | :--- |
| `adder.vhd` | Somador parametrizável |
| `flip_flop.vhd` | Flip-flop de 1 bit com habilitação e reset assíncrono |
| `generic_register.vhd` | Registrador parametrizável com habilitação e reset assíncrono |
| `clearable_register.vhd` | Registrador paralelo com clear síncrono e habilitação, composto sobre o `generic_register` |
| `mux_2x1.vhd`, `mux_4x1.vhd`, `mux_8x1.vhd`, `mux_tree.vhd` | Multiplexadores de 2, 4, 8 e N entradas |
| `onehot_decoder.vhd` | Decodificador one-hot |
| `tristate_buffer_1bit.vhd` | Buffer de três estados de 1 bit |
| `synchronizer.vhd` | Sincronizador de cruzamento de domínios de clock, com `stages` flip-flops em série e `data_width` bits independentes |
| `utils_pkg.vhd` | Tipos e funções auxiliares: comparação de vetores (`equals`, `not_equals`, `is_equal_dynamic`), inversão de bits (`reverse_vector`), redução OU e E em árvore (`reduce_or`, `reduce_and`) e `log2_ceil` |

## 3. Verificação

```bash
git clone --recurse-submodules https://github.com/insper-riscv/Common-Components.git
cd Common-Components
uv sync

make check   # verificação de sintaxe VHDL-2008 de todos os fontes, em ordem de dependência (GHDL)
make test    # testes por entidade em cocotb (make test TEST=Adder para um alvo)
make paths   # existência de todos os caminhos listados na configuração
```

Cada bloco tem um teste de entidade em `tests/python/unittests/`, e o catálogo que os conduz é o `tests/python/tests.json`. Os invólucros de teste em `tests/vhdl/` achatam os tipos que o cocotb não enxerga (`mux_tree`, `utils_pkg`). As ferramentas (GHDL e uv) vêm da imagem `ci-vhdl` do repositório [Infra](https://github.com/insper-riscv/Infra), onde a integração contínua executa.

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](LICENSE).
