# Verificação formal

🌐 [Português](../../pt-br/formal/formal.md) · [English](../../en/formal/formal.md)

As provas formais rodam no SymbiYosys sobre a netlist Verilog que o GHDL sintetiza de cada entidade, com as propriedades escritas em SystemVerilog em volta dela (`formal/<entidade>_props.sv`). O método, os engines (`yices`, `bitwuzla`, `boolector` e `abc-bmc3`), o arquivo `build/formal/result-<engine>.tsv` e a regra do agregador `formal/aggregate.sh` são os do Core. Este documento descreve o que se prova nos primitivos deste repositório.

## 1. O que se prova

| Entidade | Arquivo | Variantes provadas | Propriedades |
| :--- | :--- | :--- | :--- |
| `synchronizer` | `synchronizer_props.sv` | 2 estágios com 2 bits, 3 estágios com 1 bit | Com `stages` bordas sem reset, a saída é a entrada de `stages` bordas atrás, para toda sequência de entrada; depois de um reset a saída fica em zero até a primeira amostra chegar ao último estágio |
| `flip_flop` | `flip_flop_props.sv` | único | O reset assíncrono zera a saída no mesmo ciclo e vence o enable; com enable a borda carrega `i_d`; sem enable o valor se mantém |
| `generic_register` | `generic_register_props.sv` | 4 bits | As mesmas propriedades do `flip_flop`, para o vetor inteiro |
| `clearable_register` | `clearable_register_props.sv` | `clear_value` em `'0'` e em `'1'` | O clear vence o enable e carrega o valor de limpeza em todos os bits; com enable e sem clear a borda carrega `i_d`; sem os dois o valor se mantém |
| `config_pkg` | `config_pkg_props.sv` | padrão (RV32IM, 32 bits), `IS_64` com `ADDR_BITS` 40 e base E, trocando o `config_pkg.vhd` da lista de fontes | As relações entre `XLEN`, `NUM_REGS`, `REG_BITS` e `ADDR_BITS`, o comprimento dos subtipos, o mapa crescente dentro de $2^{ADDR\_BITS}$, o nome da ISA e a aceitação do `check_isa`; sete configurações inválidas são rejeitadas com `assertion failure` na síntese |
| `counter64` | `counter64_props.sv` | larguras 1, 20, 32, 33, 63 e 64 com a palavra de 32 bits, e 1, 33 e 64 com a palavra de 64 bits | O par de metades é sempre o valor ideal, a escrita vence o incremento, o vai-um nunca se perde, `o_wrap` é o estouro ideal e o valor não decresce sem escrita |

As propriedades dos estágios do `synchronizer` valem por indução, e cada entidade tem um cover que mostra que a situação provada é alcançável (uma amostra chega à saída, um reset esvazia a cadeia, um clear acontece junto com um enable).

## 2. Mutantes

Cada defeito proposital do VHDL precisa fazer uma prova falhar. O `formal/run.sh` aplica cada edição com `sed` numa cópia do arquivo e exige o veredito `fail`.

| Mutante | Defeito | Propriedade que o pega |
| :--- | :--- | :--- |
| `sync_short_chain` | saída um estágio antes do último | latência de `stages` bordas |
| `sync_long_chain` | saída direto do primeiro estágio | latência de `stages` bordas |
| `sync_reset_ignored` | reset síncrono ignorado | saída em zero depois do reset |
| `sync_reset_stage0_only` | reset zera só o primeiro estágio | saída em zero depois do reset |
| `ff_enable_ignored` | carrega sempre | valor mantido sem enable |
| `ff_no_async_reset` | reset só na borda do clock | reset assíncrono no mesmo ciclo |
| `ff_reset_to_one` | reset leva a `'1'` | saída zero no reset |
| `reg_enable_ignored` | carrega sempre | valor mantido sem enable |
| `reg_reset_one_bit` | reset deixa um bit em `'1'` | saída zero no reset |
| `reg_no_hold` | carrega `not i_d` | valor carregado igual a `i_d` |
| `clr_enable_wins` | enable vence o clear | prioridade do clear |
| `clr_no_clear` | clear sem carga | clear carrega o valor de limpeza |
| `clr_wrong_value` | clear sempre em zeros | valor de limpeza `'1'` |
| `carry_lost` | vai-um só quando o bit mais alto da metade baixa vale um | vai-um da metade baixa cheia |
| `width_one_bit_wider` | metade alta um bit mais larga | bits acima da largura leem zero |
| `write_adds_one` | a escrita soma um ao valor | valor escrito igual a `i_wdata` |
| `no_increment_idle` | incremento só com escrita | uma soma por ciclo habilitado |
| `wrap_without_hi` | estouro sem conferir a metade alta cheia | `o_wrap` só no estouro do contador inteiro |
| `wrap_on_lo_write` | uma escrita na metade baixa gera estouro | `o_wrap` nunca por escrita |

## 3. Rodando

```bash
make formal                          # engine padrão (bitwuzla)
make formal FORMAL_ENGINE=yices      # outro engine
```

O `abc-bmc3` pula as provas de indução e os covers, que não faz, e responde só pelos mutantes.

## 4. Aviso é erro

Qualquer aviso do GHDL, do Yosys ou do SymbiYosys faz o `formal/run.sh` falhar, nas provas e nos mutantes. O script varre a saída de cada ferramenta depois que ela termina e, para cada linha com a palavra `warning` (sem diferenciar maiúsculas, palavra inteira ou no plural), imprime `formal: WARNING treated as error: <arquivo>:<linha>:<texto>`. Nomes como `warning_count` e o resumo `Warnings: 0` do Yosys não contam.

Um aviso indica código fora da norma ou no limite, então a correção é no VHDL ou nas propriedades, nunca em uma opção que esconda o aviso (`-Wno-*`). Além das provas, a síntese do `mux_tree` sem prova passa pela mesma varredura.

O atributo `altera_attribute` do `synchronizer` só anota o sinal para o Quartus e o GHDL não o conhece, então a cópia que entra na netlist formal sai sem ele.

O engine `abc-bmc3` tem uma exceção exata, só para as três mensagens que o próprio ABC imprime sobre o arquivo AIGER recebido (o clock consumido pelo passo `clk2ff`, e a contagem de saídas lidas como restrições). Elas não descrevem o projeto nem as propriedades, e qualquer outro aviso desse engine continua falhando.

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
