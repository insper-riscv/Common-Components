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

## 3. Rodando

```bash
make formal                          # engine padrão (bitwuzla)
make formal FORMAL_ENGINE=yices      # outro engine
```

O `abc-bmc3` pula as provas de indução e os covers, que não faz, e responde só pelos mutantes.

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
