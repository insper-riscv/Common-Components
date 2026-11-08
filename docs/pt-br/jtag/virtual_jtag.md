# virtual_jtag

🌐 [Português](../../pt-br/jtag/virtual_jtag.md) · [English](../../en/jtag/virtual_jtag.md)

## 1. Finalidade

Instância única do megafunction `sld_virtual_jtag` da Intel, com o índice da instância e a largura do registrador de instrução por genérico. Os invólucros que expõem um núcleo ao hospedeiro pela JTAG instanciam esta entidade e ligam o núcleo às suas portas, sem repetir o mapa de genéricos e de portas do megafunction. Fica em `src/altera/` porque cita a biblioteca `altera_mf`, e é analisada só onde essa biblioteca existe (Quartus e simulação de topo de hardware).

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `instance_index` | `natural` | `0` | Índice da instância que o hospedeiro usa para alcançá-la. |
| `auto_instance_index` | `string` | `"NO"` | `"YES"` deixa o Quartus escolher o índice livre mais baixo, e `"NO"` fixa o índice em `instance_index`. |
| `ir_width` | `positive` | `2` | Largura do registrador de instrução virtual, em bits. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `o_tck` | out | `std_logic` | Clock da cadeia JTAG. |
| `o_tdi` | out | `std_logic` | Dado serial vindo do hospedeiro. |
| `i_tdo` | in | `std_logic` | Dado serial para o hospedeiro. |
| `o_ir_in` | out | `std_logic_vector(ir_width - 1 downto 0)` | Registrador de instrução virtual. |
| `o_state_cdr` | out | `std_logic` | Estado Capture-DR da cadeia virtual. |
| `o_state_sdr` | out | `std_logic` | Estado Shift-DR da cadeia virtual. |
| `o_state_udr` | out | `std_logic` | Estado Update-DR da cadeia virtual. |
| `o_state_uir` | out | `std_logic` | Estado Update-IR da cadeia virtual. |

## 4. Comportamento

A entidade só repassa as portas do megafunction. O registrador `ir_out` do megafunction fica em zero, e os estados Exit1-DR, Pause-DR, Exit2-DR e Capture-IR ficam sem saída, pois nenhum núcleo os usa. A entidade não tem nome igual ao do megafunction para não sombreá-lo na biblioteca `work`.

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Memory | `ROM/Cyclone-V/flash_jtag_shell.vhd`, `RAM/FPGA/Cyclone-V/sdram_jtag_shell.vhd` |
| Peripherals | `UART/jtag/cyclone-v/jtag_uart_shell.vhd`, `display/cyclone-v/seg_display_shell.vhd` |

## 5. Permanência no Common-Components

O bloco é usado pelo Memory e pelo Peripherals. Por ser o único invólucro do `sld_virtual_jtag` da Altera, ele permanece no Common-Components, e os módulos `*_jtag_shell` de cada repositório o instanciam em vez de repetir a instância da primitiva (regra 7 da seção 5 do `CONTRIBUTING.md`).

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
