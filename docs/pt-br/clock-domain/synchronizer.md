# synchronizer

🌐 [Português](../../pt-br/clock-domain/synchronizer.md) · [English](../../en/clock-domain/synchronizer.md)

## 1. Finalidade

Sincronizador de cruzamento de domínios de clock, formado por uma cadeia de flip-flops em série no domínio de `i_clk`. Só o último estágio chega à saída, e os anteriores têm um período inteiro para sair da metaestabilidade.

## 2. Genéricos

| Genérico | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `stages` | `natural` | `2` | Número de flip-flops em série, no mínimo 2. Um valor menor aborta a elaboração com `severity failure`. |
| `data_width` | `natural` | `1` | Largura de `i_d` e `o_d`, em bits. Cada bit é sincronizado de forma independente. |

## 3. Portas

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_clk` | in | `std_logic` | Clock do domínio de destino, o mesmo que consome `o_d`. |
| `i_rst` | in | `std_logic` | Reset síncrono ativo em `'1'`, com prioridade sobre `i_d`. Valor padrão `'0'`. |
| `i_d` | in | `std_logic_vector(data_width-1 downto 0)` | Sinal vindo do outro domínio. |
| `o_d` | out | `std_logic_vector(data_width-1 downto 0)` | Sinal sincronizado, atrasado de `stages` ciclos. |

## 4. Comportamento

A cadeia $c_0, \dots, c_{T-1}$, com $T$ igual a `stages`, avança um estágio a cada borda de subida de `i_clk`. O reset zera todos os estágios e a cadeia começa em zero na elaboração.

$$c_0^{+} = \begin{cases} 0 & i\_rst = 1 \\ i\_d & i\_rst = 0 \end{cases}, \qquad c_k^{+} = \begin{cases} 0 & i\_rst = 1 \\ c_{k-1} & i\_rst = 0 \end{cases} \; (k \ge 1), \qquad o\_d = c_{T-1}$$

A latência é de `stages` bordas de subida. Por serem independentes, os bits de um vetor podem chegar em ciclos diferentes, então o bloco serve para um bit de nível ou de pulso mais longo que um período de `i_clk`, para um toggle de handshake e para vetores com bits consumidos isoladamente ou codificados em Gray. Um barramento de dados deve ficar parado e ser lido só depois que o toggle que o acompanha chegar sincronizado.

No Quartus, o atributo `altera_attribute` do sinal da cadeia marca-a como sincronizador, o que a inclui no relatório de MTBF, e impede que seus registradores sejam fundidos ou removidos. O caminho que entra no primeiro estágio exige `set_false_path` ou `set_max_delay` no arquivo `.sdc`, pois os clocks não têm relação de fase.

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Memory | `RAM/FPGA/debug/sdram/sdram_dbg_master.vhd`, `RAM/SoC/sdram/sdram_ctrl.vhd`, `RAM/SoC/sdram/sdram_cpu_bridge.vhd`, `ROM/SoC/nor_flash_ctrl.vhd` |
| Peripherals | `display/soc/seg_display.vhd`, `GPIO/soc/gpio_cell.vhd`, que sincroniza o pino de entrada com dois estágios |

## 5. Permanência no Common-Components

O bloco é usado pelo Memory e pelo Peripherals. Por ser compartilhado entre repositórios, ele permanece no Common-Components. Todo sinal que cruza de um domínio de clock para outro, ou que entra de um pino assíncrono, passa por este bloco, e nenhum repositório escreve uma cadeia de sincronização própria (regra 7 da seção 5 do `CONTRIBUTING.md`).

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
