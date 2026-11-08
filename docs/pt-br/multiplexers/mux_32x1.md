# mux_32x1

🌐 [Português](../../pt-br/multiplexers/mux_32x1.md) · [English](../../en/multiplexers/mux_32x1.md)

## 1. Finalidade

Multiplexador combinacional de 32 entradas de mesma largura, composto pelo `mux_tree` com 5 estágios.

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
| `i_d8` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 8. |
| `i_d9` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 9. |
| `i_d10` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 10. |
| `i_d11` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 11. |
| `i_d12` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 12. |
| `i_d13` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 13. |
| `i_d14` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 14. |
| `i_d15` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 15. |
| `i_d16` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 16. |
| `i_d17` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 17. |
| `i_d18` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 18. |
| `i_d19` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 19. |
| `i_d20` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 20. |
| `i_d21` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 21. |
| `i_d22` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 22. |
| `i_d23` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 23. |
| `i_d24` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 24. |
| `i_d25` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 25. |
| `i_d26` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 26. |
| `i_d27` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 27. |
| `i_d28` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 28. |
| `i_d29` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 29. |
| `i_d30` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 30. |
| `i_d31` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 31. |
| `i_sel` | in | `std_logic_vector(4 downto 0)` | Seletor da entrada que chega à saída. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada. |

## 4. Comportamento

Com $k$ o valor numérico de `i_sel`, a saída é a entrada de índice $k$.

$$o\_d = i\_d_k, \quad k = \mathrm{unsigned}(i\_sel) \in \{0, 1, \dots, 31\}$$

## 5. Permanência no Common-Components

Por ser um multiplexador genérico, sem dependência de periférico, o bloco fica no Common-Components (regra 7 da seção 5 do `CONTRIBUTING.md`). Outro repositório que precise de um multiplexador de 32 entradas o importa pelo submódulo `src/common`.

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
