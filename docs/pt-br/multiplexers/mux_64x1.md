# mux_64x1

🌐 [Português](../../pt-br/multiplexers/mux_64x1.md) · [English](../../en/multiplexers/mux_64x1.md)

## 1. Finalidade

Multiplexador combinacional de 64 entradas de mesma largura, composto pelo `mux_tree` com 6 estágios.

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
| `i_d32` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 32. |
| `i_d33` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 33. |
| `i_d34` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 34. |
| `i_d35` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 35. |
| `i_d36` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 36. |
| `i_d37` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 37. |
| `i_d38` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 38. |
| `i_d39` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 39. |
| `i_d40` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 40. |
| `i_d41` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 41. |
| `i_d42` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 42. |
| `i_d43` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 43. |
| `i_d44` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 44. |
| `i_d45` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 45. |
| `i_d46` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 46. |
| `i_d47` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 47. |
| `i_d48` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 48. |
| `i_d49` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 49. |
| `i_d50` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 50. |
| `i_d51` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 51. |
| `i_d52` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 52. |
| `i_d53` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 53. |
| `i_d54` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 54. |
| `i_d55` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 55. |
| `i_d56` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 56. |
| `i_d57` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 57. |
| `i_d58` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 58. |
| `i_d59` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 59. |
| `i_d60` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 60. |
| `i_d61` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 61. |
| `i_d62` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 62. |
| `i_d63` | in | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada quando `i_sel` vale 63. |
| `i_sel` | in | `std_logic_vector(5 downto 0)` | Seletor da entrada que chega à saída. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Entrada selecionada. |

## 4. Comportamento

Com $k$ o valor numérico de `i_sel`, a saída é a entrada de índice $k$.

$$o\_d = i\_d_k, \quad k = \mathrm{unsigned}(i\_sel) \in \{0, 1, \dots, 63\}$$

## 5. Permanência no Common-Components

Por ser um multiplexador genérico, sem dependência de periférico, o bloco fica no Common-Components (regra 7 da seção 5 do `CONTRIBUTING.md`). Outro repositório que precise de um multiplexador de 64 entradas o importa pelo submódulo `src/common`.

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
