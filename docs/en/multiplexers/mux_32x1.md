# mux_32x1

🌐 [Português](../../pt-br/multiplexers/mux_32x1.md) · [English](../../en/multiplexers/mux_32x1.md)

## 1. Purpose

Combinational multiplexer with 32 inputs of equal width, built on `mux_tree` with 5 stages.

## 2. Generics

| Generic | Tipo | Default | Description |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Width of each bus, in bits. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_d0` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 0. |
| `i_d1` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 1. |
| `i_d2` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 2. |
| `i_d3` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 3. |
| `i_d4` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 4. |
| `i_d5` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 5. |
| `i_d6` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 6. |
| `i_d7` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 7. |
| `i_d8` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 8. |
| `i_d9` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 9. |
| `i_d10` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 10. |
| `i_d11` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 11. |
| `i_d12` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 12. |
| `i_d13` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 13. |
| `i_d14` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 14. |
| `i_d15` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 15. |
| `i_d16` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 16. |
| `i_d17` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 17. |
| `i_d18` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 18. |
| `i_d19` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 19. |
| `i_d20` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 20. |
| `i_d21` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 21. |
| `i_d22` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 22. |
| `i_d23` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 23. |
| `i_d24` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 24. |
| `i_d25` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 25. |
| `i_d26` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 26. |
| `i_d27` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 27. |
| `i_d28` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 28. |
| `i_d29` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 29. |
| `i_d30` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 30. |
| `i_d31` | in | `std_logic_vector(data_width-1 downto 0)` | Input selected when `i_sel` equals 31. |
| `i_sel` | in | `std_logic_vector(4 downto 0)` | Selector of the input that reaches the output. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Selected input. |

## 4. Behavior

With $k$ the numeric value of `i_sel`, the output is the input of index $k$.

$$o\_d = i\_d_k, \quad k = \mathrm{unsigned}(i\_sel) \in \{0, 1, \dots, 31\}$$

## 5. Placement in Common-Components

Being a generic multiplexer with no dependency on a peripheral, the block stays in Common-Components (rule 7 of section 5 of `CONTRIBUTING.md`). A repository that needs a 32-input multiplexer imports it through the `src/common` submodule.

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
