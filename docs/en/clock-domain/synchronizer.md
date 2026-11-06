# synchronizer

🌐 [Português](../../pt-br/clock-domain/synchronizer.md) · [English](../../en/clock-domain/synchronizer.md)

## 1. Purpose

Clock domain crossing synchronizer, made of a chain of flip-flops in series in the `i_clk` domain. Only the last stage reaches the output, and the earlier ones have a whole period to leave metastability.

## 2. Generics

| Generic | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `stages` | `natural` | `2` | Number of flip-flops in series, at least 2. A smaller value aborts elaboration with `severity failure`. |
| `data_width` | `natural` | `1` | Width of `i_d` and `o_d`, in bits. Each bit is synchronized independently. |

## 3. Ports

| Port | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `i_clk` | in | `std_logic` | Clock of the destination domain, the same one that consumes `o_d`. |
| `i_rst` | in | `std_logic` | Synchronous reset, active at `'1'`, with priority over `i_d`. Default value `'0'`. |
| `i_d` | in | `std_logic_vector(data_width-1 downto 0)` | Signal coming from the other domain. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Synchronized signal, delayed by `stages` cycles. |

## 4. Behavior

The chain $c_0, \dots, c_{T-1}$, with $T$ equal to `stages`, advances one stage on each rising edge of `i_clk`. Reset clears every stage and the chain starts at zero at elaboration.

$$c_0^{+} = \begin{cases} 0 & i\_rst = 1 \\ i\_d & i\_rst = 0 \end{cases}, \qquad c_k^{+} = \begin{cases} 0 & i\_rst = 1 \\ c_{k-1} & i\_rst = 0 \end{cases} \; (k \ge 1), \qquad o\_d = c_{T-1}$$

Latency is `stages` rising edges. Because bits are independent, the bits of a vector may arrive in different cycles, so the block suits a level bit or a pulse longer than one period of `i_clk`, a handshake toggle, and vectors whose bits are consumed alone or Gray coded. A data bus must stay still and be read only after its accompanying toggle arrives synchronized.

In Quartus, the `altera_attribute` on the chain signal marks it as a synchronizer, which includes it in the MTBF report, and prevents its registers from being merged or removed. The path entering the first stage needs `set_false_path` or `set_max_delay` in the `.sdc` file, since the clocks have no phase relation.

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Memory | `RAM/FPGA/debug/sdram/sdram_dbg_master.vhd`, `RAM/SoC/sdram/sdram_ctrl.vhd`, `RAM/SoC/sdram/sdram_cpu_bridge.vhd` |
| Peripherals | `display/soc/seg_display.vhd`, `GPIO/soc/gpio_cell.vhd`, which synchronizes the input pin with two stages, and `intc/soc/ext_irq_controller.vhd` |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
