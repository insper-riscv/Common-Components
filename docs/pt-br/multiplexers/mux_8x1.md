# mux_8x1

🌐 [Português](../../pt-br/multiplexers/mux_8x1.md) · [English](../../en/multiplexers/mux_8x1.md)

## 1. Finalidade

Multiplexador combinacional de oito entradas de mesma largura.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Largura de cada barramento, em bits. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_d0` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 0. |
| `i_d1` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 1. |
| `i_d2` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 2. |
| `i_d3` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 3. |
| `i_d4` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 4. |
| `i_d5` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 5. |
| `i_d6` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 6. |
| `i_d7` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 7. |
| `i_sel` | in | `std_logic_vector(2 downto 0)` | Seletor da entrada que chega à saída. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada. |

## 4. Comportamento

Com $k$ o valor numérico de `i_sel`, a saída é a entrada de índice $k$.

$$o\_d = i\_d_k, \quad k = \mathrm{unsigned}(i\_sel) \in \{0, 1, \dots, 7\}$$

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Peripherals | `TIMER/soc/timer.vhd`, `GPIO/soc/gpio.vhd` |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
