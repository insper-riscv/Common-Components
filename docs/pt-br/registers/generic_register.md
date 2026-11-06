# generic_register

🌐 [Português](../../pt-br/registers/generic_register.md) · [English](../../en/registers/generic_register.md)

## 1. Finalidade

Registrador paralelo de largura configurável com habilitação de carga e reset assíncrono que zera todos os bits.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `data_width` | `natural` | `8` | Largura do registrador, em bits. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_d` | in | `std_logic_vector(data_width-1 downto 0)` | Dado a armazenar. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Dado armazenado. Valor inicial zero. |
| `i_enable` | in | `std_logic` | Habilita a carga na borda de subida. |
| `i_clk` | in | `std_logic` | Clock, sensível à borda de subida. |
| `i_rst` | in | `std_logic` | Reset assíncrono ativo em `'1'`. |

## 4. Comportamento

O reset tem prioridade sobre o clock. Fora do reset, a carga só ocorre na borda de subida de `i_clk` com `i_enable` em `'1'`.

$$o\_d^{+} = \begin{cases} 0 & i\_rst = 1 \\ i\_d & i\_rst = 0 \wedge \uparrow i\_clk \wedge i\_enable = 1 \\ o\_d & \text{caso contrário} \end{cases}$$

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `shared/reg_file.vhd`, `shared/pc_fetch.vhd`, `Zicclsm/misaligned_unit.vhd`, `core/core.vhd`, `Zicntr/counter64.vhd`, `M/muldiv_fusion.vhd`, `M/multdiv.vhd`, `Zicsr/csr_file.vhd`, `Zihpm/hpm_counter_bank.vhd` |
| Peripherals | `CLINT/soc/clint.vhd`, `CLINT/soc/clint_mtime.vhd` |
| Common-Components | `clearable_register.vhd`, que a instancia internamente |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
