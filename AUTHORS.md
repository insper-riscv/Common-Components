# Autores

🌐 [Português](AUTHORS.md) · [English](AUTHORS.en.md)

Este repositório faz parte do Capstone de Engenharia de Computação e Ciência da Computação do [Insper](https://www.insper.edu.br), liderado pelo professor **Rafael Corsi Ferrão** ([@rafaelcorsi](https://github.com/rafaelcorsi)) e financiado pelo [CTI Renato Archer](https://www.gov.br/cti/pt-br). A lista abaixo reúne as pessoas que escreveram os blocos que o `Common-Components` reúne, conforme o histórico de commits dos repositórios de origem (o `RV32` antes da divisão, o `Core` e o `Peripherals`).

## 1. Autores deste Módulo

| Período | Nome | Conta no GitHub | Blocos de origem |
| :--- | :--- | :--- | :--- |
| 2026.2 | Lucas Hix | [@Peng1104](https://github.com/Peng1104) | `mux_tree`, `onehot_decoder` e as funções `equals`, `not_equals` e `log2_ceil` do `utils_pkg`; a reorganização de todos os blocos (nomes em `snake_case` e portas `i_` e `o_`); a versão atual do `mux_4x1`, o `mux_8x1`, o `clearable_register` e o `tristate_buffer_1bit`; os testes e a integração contínua |
| 2025.2 | Ilana Chaia Finger | [@ilacftemp](https://github.com/ilacftemp) | os multiplexadores genéricos de 2 e 4 entradas (`muxGenerico2x1` e `muxGenerico4x1`), de onde vêm o `mux_2x1` e o `mux_4x1`, e a primeira versão do registrador genérico, de onde vem o `generic_register` |
| 2025.2 | Lucas Fernando De Souza Lima | [@lucasouzamil](https://github.com/lucasouzamil) | o somador genérico (`genericAdder` e `genericAdderU`, origem do `adder`), o flip-flop (`FlipFlop`, origem do `flip_flop`), o multiplexador genérico (`genericMux2x1`) e o registrador com clear síncrono do temporizador, de onde vem o `clearable_register` |
| 2025.2 | Leonardo Merlin Paloschi | [@leonardopaloschi](https://github.com/leonardopaloschi) | o multiplexador de 8 entradas (`GENERIC_MUX_8X1`, origem do `mux_8x1`), o buffer de três estados (`TRISTATE_BUFFER_1BIT`, origem do `tristate_buffer_1bit`), o flip-flop com clear síncrono (`GENERIC_FLIP_FLOP`) e o pacote `GENERICS`, de onde vêm `reverse_vector`, `reduce_or`, `reduce_and` e `is_equal_dynamic` do `utils_pkg` |

## 2. Histórico do Projeto

Cada grupo do Capstone continuou o trabalho do anterior. A lista completa dos grupos, incluindo quem não fez commits nos blocos deste repositório, está no [README da organização](https://github.com/insper-riscv/.github/blob/main/profile/README.md).

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](LICENSE).
