# config_pkg

🌐 [Português](../../pt-br/packages/config_pkg.md) · [English](../../en/packages/config_pkg.md)

## 1. Finalidade

Pacote de constantes de elaboração que espelha, em VHDL, a configuração que o `platform.yaml` escolhe: a base da ISA, a largura do endereço físico, as extensões, as caches, os periféricos e o mapa de memória em bytes. Todo módulo lê as constantes e usa `generate` sobre elas, de modo que extensão desligada não gera lógica.

O Common-Components traz o pacote com os valores padrão (RV32IM, endereço de 32 bits, sem periféricos), que os testes dos módulos usam. O topo de uma plataforma e as provas formais trocam este arquivo, na lista de fontes, por uma versão gerada com o mesmo nome de unidade e as mesmas constantes. O pacote não é genérico porque o Quartus Prime Lite recusa pacote genérico.

## 2. Parâmetros

Cada parâmetro é uma constante do pacote. A coluna do valor traz o padrão deste repositório.

### 2.1. Base e largura

| Constante | Tipo | Padrão | Faixa | Significado |
| :--- | :--- | :--- | :--- | :--- |
| `IS_64` | `boolean` | `false` | | Base de 64 bits (RV64) quando verdadeiro, de 32 bits (RV32) quando falso |
| `IS_BASE_E` | `boolean` | `false` | | Base E, com 16 registradores, quando verdadeiro; base I, com 32, quando falso |
| `ADDR_BITS` | `natural` | 32 | 16 a 64, acima de 32 só com `IS_64` | Largura do endereço físico, em bits |
| `XLEN` | `natural` | 32 | 32 ou 64 | Largura da palavra de dados, do PC lógico e dos registradores, derivada de `IS_64` |
| `REG_BITS` | `natural` | 5 | 4 ou 5 | Largura do índice de registrador, derivada de `IS_BASE_E` |
| `NUM_REGS` | `natural` | 32 | 16 ou 32 | Número de registradores de uso geral, $2^{REG\_BITS}$ |

$$XLEN = \begin{cases} 64 & IS\_64 \\ 32 & \text{caso contrário} \end{cases} \qquad REG\_BITS = \begin{cases} 4 & IS\_BASE\_E \\ 5 & \text{caso contrário} \end{cases}$$

### 2.2. Subtipos

| Subtipo | Definição | Descrição |
| :--- | :--- | :--- |
| `word_t` | `std_logic_vector(XLEN-1 downto 0)` | Palavra de dados |
| `reg_t` | `std_logic_vector(REG_BITS-1 downto 0)` | Índice de registrador |
| `addr_t` | `std_logic_vector(ADDR_BITS-1 downto 0)` | Endereço físico |
| `map_addr_t` | `unsigned(ADDR_BITS downto 0)` | Endereço de mapa em bytes, com um bit a mais para representar o fim exclusivo $2^{ADDR\_BITS}$ |

### 2.3. Extensões e opções do núcleo

Todas são `boolean`. Os valores padrão são `HAS_M` e `HAS_ZICCLSM` verdadeiros e os demais falsos.

| Constante | Significado | Exige |
| :--- | :--- | :--- |
| `HAS_M` | Multiplicação e divisão | |
| `HAS_ZMMUL` | Só multiplicação (`HAS_M` já a inclui) | |
| `HAS_ZICSR` | Zicsr e tratamento de exceções do modo máquina | |
| `HAS_ZICNTR` | Contadores `mcycle`, `minstret` e `time` | `HAS_ZICSR` |
| `HAS_ZIHPM` | Contadores de eventos | `HAS_ZICSR` |
| `HAS_ZIMOP` | `mop.r.n` e `mop.rr.n` | |
| `HAS_ZICOND` | `czero.eqz` e `czero.nez` | |
| `HAS_ZIHINTNTL` | Dicas `ntl.*` | |
| `HAS_ZIHINTPAUSE` | Dica `pause` | |
| `HAS_ZIFENCEI` | `fence.i` | |
| `HAS_ZICCLSM` | Acesso desalinhado à memória principal em hardware | |
| `HAS_INTERRUPTS` | Interrupções de máquina (`mip` e `mie`) | `HAS_ZICSR` |
| `HAS_SSCOFPMF` | Estouro de contador de eventos | `HAS_ZIHPM` e `HAS_INTERRUPTS` |
| `HAS_ACCESS_FAULTS` | Falhas de acesso (causas 1, 5 e 7) fora do mapa válido | `HAS_ZICSR` |
| `HAS_ICACHE` | Cache de instruções | |
| `HAS_DCACHE` | Cache de dados | |

### 2.4. Mapa de memória

Os endereços são `map_addr_t`, em bytes. O mapa é crescente e cabe no espaço de $2^{ADDR\_BITS}$ bytes.

| Constante | Tipo | Padrão | Significado |
| :--- | :--- | :--- | :--- |
| `BOOT_MEMORY_BITS` | `natural` | 12 | A `BOOT_MEMORY` ocupa $[0, 2^{BOOT\_MEMORY\_BITS})$ |
| `ROM_BASE` | `map_addr_t` | `0x1000` | Base da ROM, logo depois da `BOOT_MEMORY` |
| `ROM_END` | `map_addr_t` | `0x8000` | Fim exclusivo da ROM |
| `ROM_EXTERNAL` | `boolean` | `false` | A ROM é alcançada pela porta do núcleo |
| `RAM_BASE` | `map_addr_t` | `0x8000` | Base da RAM |
| `RAM_END` | `map_addr_t` | `0x40000000` | Fim exclusivo da RAM |
| `RAM_EXTERNAL` | `boolean` | `false` | A RAM é alcançada pela porta do núcleo |
| `EXT_BASE` | `map_addr_t` | `0x40000000` | Base da janela externa |
| `PERIPH_BASE` | `map_addr_t` | `0x80000000` | Base da janela de periféricos, $2^{ADDR\_BITS-1}$ por padrão |
| `CACHE_WINDOW_BITS` | `natural` | 26 | Largura da janela de endereços das caches |

### 2.5. Periféricos

Todas as constantes são `boolean` e valem `false` por padrão: `HAS_UART`, `HAS_UART_PINS`, `HAS_UART_JTAG`, `HAS_TIMER`, `HAS_GPIO`, `HAS_DISPLAY`, `HAS_SWITCHES`, `HAS_KEYS`, `HAS_CLINT`, `HAS_PLIC` e `HAS_FLASH_CTRL`.

### 2.6. Constantes compostas

| Constante | Definição |
| :--- | :--- |
| `HAS_MULDIV` | `HAS_M` ou `HAS_ZMMUL` |
| `HAS_ANY_COUNTER` | `HAS_ZICNTR` ou `HAS_ZIHPM` |
| `HAS_SSCOF` | `HAS_SSCOFPMF`, `HAS_ZIHPM` e `HAS_INTERRUPTS` |

## 3. Funções

| Função | Retorno | Descrição |
| :--- | :--- | :--- |
| `isa_string` | `string` | Nome da ISA configurada na ordem canônica das extensões, como `rv32im_zicclsm` |
| `check_isa` | `boolean` | Confere as dependências e as faixas abaixo, falha na elaboração com `severity failure` quando alguma não vale e devolve `true` |

A entidade de topo da cadeia chama `check_isa` uma vez, no `generate` (`if check_isa generate`), e imprime `isa_string` num `report`. A chamada não fica em constante do pacote, porque o GHDL avisa que a função é chamada antes de o corpo ser elaborado.

Condições que `check_isa` exige.

| Condição | Mensagem de falha |
| :--- | :--- |
| `HAS_ZICNTR` ou `HAS_ZIHPM` implicam `HAS_ZICSR` | `Zicntr e Zihpm exigem Zicsr` |
| `HAS_INTERRUPTS` implica `HAS_ZICSR` | `interrupcoes exigem Zicsr` |
| `HAS_SSCOFPMF` implica `HAS_ZIHPM` e `HAS_INTERRUPTS` | `Sscofpmf exige Zihpm e interrupcoes` |
| `HAS_ACCESS_FAULTS` implica `HAS_ZICSR` | `falhas de acesso exigem Zicsr` |
| $16 \le ADDR\_BITS \le 64$ | `ADDR_BITS fora de 16..64` |
| $ADDR\_BITS > 32$ implica `IS_64` | `ADDR_BITS > 32 exige IS_64` |
| $BOOT\_MEMORY\_BITS < ADDR\_BITS$ | `BOOT_MEMORY_BITS deve ser menor que ADDR_BITS` |
| $2^{BOOT\_MEMORY\_BITS} \le ROM\_BASE$ | `a ROM deve comecar depois da BOOT_MEMORY` |
| $ROM\_END \le RAM\_BASE$ | `a ROM deve terminar antes da RAM` |
| $RAM\_BASE < RAM\_END$ | `a RAM deve ter tamanho positivo` |
| $RAM\_END \le EXT\_BASE$ | `a RAM deve terminar antes da janela externa` |
| $EXT\_BASE \le PERIPH\_BASE$ | `a janela externa deve terminar antes dos perifericos` |
| $PERIPH\_BASE < 2^{ADDR\_BITS}$ | `a janela de perifericos deve caber em 2**ADDR_BITS` |

## 4. Verificação

O `config_pkg_tb` expõe as constantes como portas. O teste de entidade confere a configuração padrão e, com cópias do pacote de uma constante alterada, confere que cada condição de `check_isa` interrompe a elaboração. A prova formal troca o arquivo na lista de fontes por variantes (`IS_64` verdadeiro com `ADDR_BITS` 40, e base E) e prova as relações de largura e de mapa em cada uma.

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Common-Components | `counter64.vhd` e `tests/vhdl/config_pkg_tb.vhd` |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
