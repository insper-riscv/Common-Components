# counter64

🌐 [Português](../../pt-br/counters/counter64.md) · [English](../../en/counters/counter64.md)

## 1. Finalidade

Contador de até 64 bits guardado em duas metades, com vai-um registrado. A metade baixa guarda os $\min(width, XLEN)$ bits baixos e a alta os $width - XLEN$ restantes, ausente quando o contador cabe na baixa. A largura da palavra $XLEN$ vem do [config_pkg](../packages/config_pkg.md), de modo que no RV32 cada metade tem até 32 bits e no RV64 um contador de 64 bits cabe inteiro na metade baixa. Nenhuma soma de 64 bits entra em um caminho combinacional.

## 2. Genéricos

| Genérico | Tipo | Padrão | Faixa | Descrição |
| :--- | :--- | :--- | :--- | :--- |
| `width` | `positive` | 64 | 1 a 64 | Largura do contador, em bits |

## 3. Portas

### 3.1. Controle

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_clk` | in | `std_logic` | Clock, sensível à borda de subida |
| `i_rst` | in | `std_logic` | Reset ativo em `'1'`, que zera as duas metades e o vai-um |
| `i_inc` | in | `std_logic` | Soma 1 ao contador neste ciclo quando `'1'` |

### 3.2. Escrita

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `i_we_lo` | in | `std_logic` | Escreve a metade baixa com `i_wdata` quando `'1'` |
| `i_we_hi` | in | `std_logic` | Escreve a metade alta com `i_wdata` quando `'1'` |
| `i_wdata` | in | `word_t` | Valor escrito na metade selecionada |

### 3.3. Leitura

| Porta | Sentido | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| `o_lo` | out | `word_t` | Metade baixa do contador |
| `o_hi` | out | `word_t` | Metade alta, já com o vai-um pendente somado |
| `o_wrap` | out | `std_logic` | Pulso de um ciclo quando uma soma leva o contador inteiro de todos os bits em `'1'` a zero |

## 4. Comportamento

| Aspecto | Comportamento |
| :--- | :--- |
| Incremento | A metade baixa soma 1 nos ciclos com `i_inc` em `'1'` |
| Vai-um | Quando a metade baixa estava com todos os bits em `'1'`, o vai-um fica registrado e a metade alta soma 1 no ciclo seguinte |
| Leitura | A metade alta lida já inclui o vai-um pendente, então o par $(o\_hi, o\_lo)$ é sempre o valor ideal do contador |
| Escrita na metade baixa | Substitui o valor e cancela o incremento e o vai-um do mesmo ciclo |
| Escrita na metade alta | Substitui o valor e descarta o vai-um pendente |
| Largura | Os bits de cada saída acima da largura da metade leem zero, e uma escrita guarda só os bits que cabem |
| Estouro | `o_wrap` pulsa quando uma soma, nunca uma escrita, leva o contador inteiro a zero |

Uma escrita vence o incremento do próprio ciclo, em cada metade. Num contador que cabe na metade baixa, `o_wrap` sai registrado, um ciclo depois da soma. Num contador com metade alta, `o_wrap` vale no ciclo em que o vai-um pendente leva a metade alta de todos os bits em `'1'` a zero, que é o ciclo seguinte ao da soma.

$$value = o\_hi \cdot 2^{XLEN} + o\_lo$$

## 5. Verificação

| Prova | Arquivo | O que garante |
| :--- | :--- | :--- |
| `counter64` | `formal/counter64_props.sv` | O par de metades é sempre o valor ideal, a escrita vence o incremento, o vai-um nunca se perde, `o_wrap` é o estouro ideal e o valor não decresce sem escrita (indução, cover), nas larguras 1, 20, 32, 33, 63 e 64 e com a palavra de 32 e de 64 bits |

## 6. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Core | `Zicsr/csr_file.vhd` (`mcycle`, `minstret`, `time`) e `Zihpm/hpm_counter_bank.vhd` (contadores de eventos) |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
