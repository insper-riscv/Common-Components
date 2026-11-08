# tristate_buffer_1bit

🌐 [Português](../../pt-br/io/tristate_buffer_1bit.md) · [English](../../en/io/tristate_buffer_1bit.md)

## 1. Finalidade

Buffer de três estados de um bit, que permite a vários drivers dividirem um mesmo pino ou barramento bidirecional.

## 2. Genéricos

A entidade não possui genéricos.

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_d` | in | `std_logic` | Dado conduzido quando o buffer está habilitado. |
| `i_enable` | in | `std_logic` | Habilitação do driver. |
| `o_d` | out | `std_logic` | Saída de três estados. |

## 4. Comportamento

$$o\_d = \begin{cases} i\_d & i\_enable = 1 \\ \text{Z} & \text{caso contrário} \end{cases}$$

O símbolo Z indica alta impedância.

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Peripherals | `TIMER/soc/timer.vhd`, `GPIO/soc/gpio_cell.vhd` |

## 5. Permanência no Common-Components

O bloco é usado apenas pelo Peripherals, nos pinos bidirecionais. Por ser o primitivo único de saída em alta impedância, ele permanece no Common-Components (regra 7 da seção 5 do `CONTRIBUTING.md`). Todo pino que precise de saída tri-state usa este bloco, e o `'Z'` fica restrito a ele.

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
