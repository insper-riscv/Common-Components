# flip_flop

🌐 [Português](../../pt-br/registers/flip_flop.md) · [English](../../en/registers/flip_flop.md)

## 1. Finalidade

Flip-flop tipo D de um bit com habilitação de carga e reset assíncrono.

## 2. Genéricos

A entidade não possui genéricos.

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_d` | in | `std_logic` | Bit a armazenar. Valor padrão `'0'`. |
| `o_d` | out | `std_logic` | Bit armazenado. Valor inicial `'0'`. |
| `i_enable` | in | `std_logic` | Habilita a carga na borda de subida. Valor padrão `'0'`. |
| `i_clk` | in | `std_logic` | Clock, sensível à borda de subida. |
| `i_rst` | in | `std_logic` | Reset assíncrono ativo em `'1'`. Valor padrão `'1'`, de modo que uma porta deixada sem ligação mantém o bit em zero. |

## 4. Comportamento

O reset tem prioridade sobre o clock. Fora do reset, a carga só ocorre na borda de subida de `i_clk` com `i_enable` em `'1'`.

$$o\_d^{+} = \begin{cases} 0 & i\_rst = 1 \\ i\_d & i\_rst = 0 \wedge \uparrow i\_clk \wedge i\_enable = 1 \\ o\_d & \text{caso contrário} \end{cases}$$

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `Zicclsm/misaligned_unit.vhd`, `Zifencei/fencei_unit.vhd`, `core/core.vhd`, `Zicsr/csr_file.vhd`, `Zicntr/counter64.vhd`, `M/multdiv.vhd`, `M/muldiv_fusion.vhd` |
| Peripherals | `TIMER/soc/clock_prescaler.vhd`, `TIMER/soc/timer.vhd`, `GPIO/soc/gpio_cell.vhd` |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
