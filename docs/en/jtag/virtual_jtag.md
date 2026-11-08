# virtual_jtag

🌐 [Português](../../pt-br/jtag/virtual_jtag.md) · [English](../../en/jtag/virtual_jtag.md)

## 1. Purpose

Single instance of Intel's `sld_virtual_jtag` megafunction, with the instance index and the instruction register width as generics. The shells that expose a core to the host over JTAG instantiate this entity and connect the core to its ports, without repeating the megafunction's generic and port maps. It lives in `src/altera/` because it cites the `altera_mf` library, and it is analyzed only where that library exists (Quartus and the hardware-top simulation).

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `instance_index` | `natural` | `0` | Index of the instance the host uses to reach it. |
| `auto_instance_index` | `string` | `"NO"` | `"YES"` lets Quartus pick the lowest free index, and `"NO"` pins the index to `instance_index`. |
| `ir_width` | `positive` | `2` | Width of the virtual instruction register, in bits. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `o_tck` | out | `std_logic` | JTAG chain clock. |
| `o_tdi` | out | `std_logic` | Serial data from the host. |
| `i_tdo` | in | `std_logic` | Serial data to the host. |
| `o_ir_in` | out | `std_logic_vector(ir_width - 1 downto 0)` | Virtual instruction register. |
| `o_state_cdr` | out | `std_logic` | Capture-DR state of the virtual chain. |
| `o_state_sdr` | out | `std_logic` | Shift-DR state of the virtual chain. |
| `o_state_udr` | out | `std_logic` | Update-DR state of the virtual chain. |
| `o_state_uir` | out | `std_logic` | Update-IR state of the virtual chain. |

## 4. Behavior

The entity only forwards the megafunction's ports. The megafunction's `ir_out` register stays at zero, and the Exit1-DR, Pause-DR, Exit2-DR and Capture-IR states are left unconnected, since no core uses them. The entity does not share the megafunction's name so that it does not shadow it in the `work` library.

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Memory | `ROM/Cyclone-V/flash_jtag_shell.vhd` |
| Peripherals | `UART/jtag/cyclone-v/jtag_uart_shell.vhd`, `display/cyclone-v/seg_display_shell.vhd` |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
