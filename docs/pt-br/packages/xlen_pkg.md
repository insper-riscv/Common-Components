# xlen_pkg

🌐 [Português](../../pt-br/packages/xlen_pkg.md) · [English](../../en/packages/xlen_pkg.md)

## 1. Finalidade

Pacote genérico do VHDL-2008 que fixa, na instanciação, a largura do dado e a do índice de registrador. Quem o usa instancia o pacote uma vez com os valores do seu perfil e passa a dispor dos subtipos `word_t` e `reg_t`.

## 2. Declarações

| Declaração | Tipo | Descrição |
| :--- | :--- | :--- |
| `xlen` | generic natural, padrão 32 | Largura em bits do dado, do PC e dos registradores. Só 32 e 64 são válidos, e quem instancia o pacote confere o valor com um `assert`, pois um pacote não executa assertivas. |
| `rve` | generic boolean, padrão `false` | Verdadeiro na base E, com índice de registrador de 4 bits, e falso na base I, com 5 bits. |
| `WORD_BITS` | constante | Igual a `xlen`. |
| `REG_ADDR_BITS` | constante | Largura do índice de registrador, $5 - [rve]$. |
| `NUM_REGS` | constante | Quantidade de registradores de uso geral, $2^{REG\_ADDR\_BITS}$. |
| `word_t` | subtipo | `std_logic_vector(WORD_BITS-1 downto 0)`. |
| `reg_t` | subtipo | `std_logic_vector(REG_ADDR_BITS-1 downto 0)`. |

## 3. Comportamento

A instanciação tem a forma

```vhdl
package isa_p is new work.xlen_pkg generic map (xlen => 64, rve => false);
```

e as constantes derivam dos dois genéricos.

$$WORD\_BITS = xlen, \qquad REG\_ADDR\_BITS = 5 - [rve], \qquad NUM\_REGS = 2^{REG\_ADDR\_BITS}$$

A base I (`rve` falso) resulta em 32 registradores e a base E (`rve` verdadeiro) em 16.

## 4. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Common-Components | `tests/vhdl/xlen_pkg_tb.vhd`, único instanciador do pacote |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
