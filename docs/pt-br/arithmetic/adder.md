# adder

🌐 [Português](../../pt-br/arithmetic/adder.md) · [English](../../en/arithmetic/adder.md)

## 1. Finalidade

Somador combinacional sem sinal de dois operandos de mesma largura. A soma é truncada na largura dos operandos, de modo que o vai-um final é descartado.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `32` | Largura dos operandos e da saída, em bits. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_a` | in | `std_logic_vector(data_width-1 downto 0)` | Primeiro operando. |
| `i_b` | in | `std_logic_vector(data_width-1 downto 0)` | Segundo operando. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Soma dos operandos. |

## 4. Comportamento

O resultado é a soma módulo $2^{W}$, com $W$ igual ao genérico `data_width`.

$$o\_d = (i\_a + i\_b) \bmod 2^{W}$$

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `shared/pc_fetch.vhd`, `core/stage_ex.vhd`, `M/multdiv.vhd` |
| Peripherals | `TIMER/soc/clock_prescaler.vhd`, `TIMER/soc/timer.vhd` |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
