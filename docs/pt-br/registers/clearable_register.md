# clearable_register

🌐 [Português](../../pt-br/registers/clearable_register.md) · [English](../../en/registers/clearable_register.md)

## 1. Finalidade

Registrador paralelo com clear síncrono e habilitação de carga, sem reset assíncrono. É composto sobre o `generic_register`, cuja entrada de reset fica ligada em `'0'`.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `32` | Largura do registrador, em bits. |
| `clear_value` | `std_logic` | `'0'` | Valor que cada bit assume no clear. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_clk` | in | `std_logic` | Clock, sensível à borda de subida. |
| `i_clear` | in | `std_logic` | Clear síncrono, com prioridade sobre `i_enable`. |
| `i_enable` | in | `std_logic` | Habilita a carga de `i_d`. |
| `i_d` | in | `std_logic_vector(data_width-1 downto 0)` | Dado a armazenar. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Valor armazenado. |

## 4. Comportamento

Na borda de subida de `i_clk` vale a prioridade a seguir, com $C$ igual ao vetor de `data_width` bits repetindo `clear_value`.

$$o\_d^{+} = \begin{cases} C & i\_clear = 1 \\ i\_d & i\_clear = 0 \wedge i\_enable = 1 \\ o\_d & \text{caso contrário} \end{cases}$$

A entidade interna recebe habilitação $i\_clear \vee i\_enable$ e dado $C$ no clear, ou `i_d` fora dele.

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Peripherals | `TIMER/soc/clock_prescaler.vhd`, `TIMER/soc/timer.vhd`, `GPIO/soc/gpio_cell.vhd` |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
