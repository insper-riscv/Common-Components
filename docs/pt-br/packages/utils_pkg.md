# utils_pkg

🌐 [Português](../../pt-br/packages/utils_pkg.md) · [English](../../en/packages/utils_pkg.md)

## 1. Finalidade

Pacote de tipos e funções combinacionais auxiliares, resolvidas em tempo de elaboração ou como lógica sem estado.

## 2. Declarações

| Declaração | Tipo | Descrição |
| :--- | :--- | :--- |
| `word_array_t` | tipo | Matriz não restrita de vetores `std_logic_vector`, usada como conjunto de palavras. |
| `equals(a, b)` | função | Retorna `'1'` quando `a` e `b` são iguais bit a bit. |
| `not_equals(a, b)` | função | Retorna `'1'` quando `a` e `b` diferem em ao menos um bit. |
| `is_equal_dynamic(l, r)` | função | Igualdade bit a bit por redução E em árvore. |
| `reverse_vector(l)` | função | Devolve `l` com a ordem dos bits invertida. |
| `reduce_or(l)` | função | Redução OU em árvore, de profundidade $O(\log n)$. |
| `reduce_and(l)` | função | Redução E em árvore, de profundidade $O(\log n)$. |
| `log2_ceil(arg)` | função | Menor $n$ natural com $2^{n} \ge arg$. |
| `is_power_of_two(arg)` | função | Verdadeiro quando `arg` é potência de dois. Zero não é. |
| `log2_exact(arg)` | função | Devolve $n$ com $2^{n} = arg$ e aborta a elaboração com `severity failure` quando `arg` não é potência de dois. |

## 3. Comportamento

Os vetores de `equals` e `not_equals` são lidos posição a posição a partir do bit menos significativo e têm de ter a mesma largura.

$$\mathrm{equals}(a, b) = \bigwedge_{i} (a_i \odot b_i), \qquad \mathrm{not\_equals}(a, b) = \bigvee_{i} (a_i \oplus b_i)$$

A função `is_equal_dynamic` calcula $\mathrm{reduce\_and}(l \odot r)$. As reduções dividem o vetor ao meio em $m = \lfloor (\mathrm{high} + \mathrm{low}) / 2 \rfloor$ e combinam as duas metades, o que dá uma árvore com $\lceil \log_2 n \rceil$ níveis de portas, em vez da cadeia linear da biblioteca IEEE. Um vetor de um bit devolve o próprio bit.

A inversão de ordem satisfaz $\mathrm{result}[i] = l[\mathrm{high} + \mathrm{low} - i]$.

As funções de largura valem, para `arg` positivo,

$$\mathrm{log2\_ceil}(arg) = \min \{ n \in \mathbb{N} \mid 2^{n} \ge arg \}, \qquad \mathrm{is\_power\_of\_two}(arg) \iff arg \ne 0 \wedge 2^{\mathrm{log2\_ceil}(arg)} = arg$$

e `log2_exact` devolve $\mathrm{log2\_ceil}(arg)$ depois de conferir a condição de potência de dois. Assim, `log2_ceil(1)` vale 0 e `log2_exact(6)` falha.

## 4. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `word_array_t` em `shared/reg_file.vhd` e `Zihpm/hpm_counter_bank.vhd`; `equals` e `not_equals` em `shared/reg_file.vhd` (bypass do banco de registradores); `log2_ceil` em `I-E/alu.vhd` (largura do deslocamento) |
| Memory | `log2_exact` em `RAM/FPGA/Cyclone-V/ram.vhd`, `RAM/SoC/ram_chip.vhd`, `RAM/SoC/ram_simulation.vhd`, `RAM/SoC/onchip_ram_port.vhd`, `RAM/SoC/sim/onchip_ram_system.vhd`, `cache/SoC/icache.vhd`, `cache/SoC/dcache.vhd`, `cache/SoC/flash_chip.vhd`, `cache/SoC/flash_cmd_port.vhd`, `cache/SoC/sim/flash_dual_system.vhd`, `ROM/Cyclone-V/boot_rom.vhd`, `ROM/Cyclone-V/flash.vhd`, `ROM/Cyclone-V/flash_store.vhd`, `ROM/SoC/rom_simulation.vhd`, `ROM/SoC/flash_simulation.vhd` e `ROM/SoC/sim/flash_system.vhd`; `word_array_t` em `RAM/SoC/ram_chip.vhd` |
| Peripherals | `log2_exact` em `flash-controller/soc/flash_controller.vhd` |
| Insper-RISC-V | `log2_exact` em `src/cyclone-v/de0-cv/de0-cv_top.vhd`, `src/cyclone-v/external-data/external-data_top.vhd`, `src/cyclone-v/external-data/external-data_sim_top.vhd`, `src/simulation/modular/modular_sim_top.vhd`, `src/simulation/internal-mem/quartus/core_fpga_test.vhd` e `src/simulation/template/rtl/template_sim_top.vhd` |
| Common-Components | `mux_tree.vhd`, que usa `word_array_t` |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
