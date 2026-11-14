# config_pkg

🌐 [Português](../../pt-br/packages/config_pkg.md) · [English](../../en/packages/config_pkg.md)

## 1. Finalidade

Pacote de constantes de elaboração que espelha, em VHDL, a configuração que o `platform.yaml` escolhe: a base da ISA, a largura do endereço físico, as extensões, as caches e o mapa de memória em bytes. Todo módulo lê as constantes e usa `generate` sobre elas, de modo que extensão desligada não gera lógica. Os tipos `word_t`, `reg_t`, `addr_t` e `map_addr_t` do pacote são os tipos de dado, de índice de registrador e de endereço de todos os módulos.

O Common-Components traz o pacote com os valores padrão (RV32I com Zicclsm, endereço de 32 bits), que os testes dos módulos usam. O topo de uma plataforma e as provas formais trocam este arquivo, na lista de fontes, por uma versão gerada com o mesmo nome de unidade e as mesmas constantes. O pacote não é genérico porque o Quartus Prime Lite recusa pacote genérico.

## 2. Parâmetros

Cada parâmetro é uma constante do pacote. A coluna do valor traz o padrão deste repositório.

### 2.1. Base e largura

| Constante | Tipo | Padrão | Faixa | Significado |
| :--- | :--- | :--- | :--- | :--- |
| `IS_64` | `boolean` | `false` | | Base de 64 bits (RV64) quando verdadeiro, de 32 bits (RV32) quando falso |
| `IS_E` | `boolean` | `false` | | Base E, com 16 registradores, quando verdadeiro; base I, com 32, quando falso |
| `ADDR_BITS` | `natural` | 32 | 16 a `XLEN` | Largura do endereço físico, em bits |
| `XLEN` | `natural` | 32 | 32 ou 64 | Largura da palavra de dados, do PC lógico e dos registradores, derivada de `IS_64` |
| `REG_BITS` | `natural` | 5 | 4 ou 5 | Largura do índice de registrador, derivada de `IS_E` |
| `NUM_REGS` | `natural` | 32 | 16 ou 32 | Número de registradores de uso geral, $2^{REG\_BITS}$ |

$$XLEN = \begin{cases} 64 & IS\_64 \\ 32 & \text{caso contrário} \end{cases} \qquad REG\_BITS = \begin{cases} 4 & IS\_E \\ 5 & \text{caso contrário} \end{cases}$$

O núcleo não tem MMU nem paginação: o endereço de um acesso é a soma de um registrador com um imediato, calculada em `XLEN` bits, então nunca passa de `XLEN` bits. Por isso `ADDR_BITS` vai até `XLEN`, e um endereço físico de 40 bits só existe na base de 64 bits. Na RV64 um `ADDR_BITS` menor que 64 é válido, e os bits altos do endereço efetivo são ignorados.

### 2.2. Subtipos

| Subtipo | Definição | Descrição |
| :--- | :--- | :--- |
| `word_t` | `std_logic_vector(XLEN-1 downto 0)` | Palavra de dados |
| `reg_t` | `std_logic_vector(REG_BITS-1 downto 0)` | Índice de registrador |
| `addr_t` | `std_logic_vector(ADDR_BITS-1 downto 0)` | Endereço físico |
| `map_addr_t` | `unsigned(ADDR_BITS downto 0)` | Endereço de mapa em bytes, com um bit a mais para representar o fim exclusivo $2^{ADDR\_BITS}$ |

### 2.3. Extensões e opções do núcleo

Todas são `boolean`. O valor padrão é verdadeiro em `HAS_ZICCLSM` e falso nas demais.

| Constante | Significado | Exige |
| :--- | :--- | :--- |
| `HAS_M` | Multiplicação e divisão; com ela, `HAS_ZMMUL` é ignorada | |
| `HAS_ZMMUL` | Só multiplicação | |
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

### 2.4. Sistema de memória

O acesso a uma região segue a própria região: a `BOOT_MEMORY` é sempre direta, a FLASH e a RAM são diretas ou pelo barramento conforme `FLASH_ON_BUS` e `RAM_ON_BUS`, e todo o resto vai pelo barramento. A região só escolhe a cache.

| Constante | Tipo | Padrão | Significado | Exige |
| :--- | :--- | :--- | :--- | :--- |
| `FLASH_ON_BUS` | `boolean` | `false` | A FLASH é alcançada pelo barramento (verdadeiro) ou pela porta direta do núcleo (falso) | |
| `RAM_ON_BUS` | `boolean` | `false` | A RAM é alcançada pelo barramento (verdadeiro) ou pela porta direta do núcleo (falso) | |
| `HAS_ICACHE` | `boolean` | `false` | Cache de instruções | `FLASH_ON_BUS` |
| `HAS_DCACHE` | `boolean` | `false` | Cache de dados | `RAM_ON_BUS` |
| `I_CACHE_WINDOW_BITS` | `natural` | 12 | Largura em bits da janela de endereços da cache de instruções (12 = 4 KiB) | |
| `D_CACHE_WINDOW_BITS` | `natural` | 12 | Largura em bits da janela de endereços da cache de dados (12 = 4 KiB) | |

### 2.5. Mapa de memória

Os endereços são `map_addr_t`, em bytes. O mapa é crescente e cabe no espaço de $2^{ADDR\_BITS}$ bytes.

| Constante | Tipo | Padrão | Significado |
| :--- | :--- | :--- | :--- |
| `BOOT_MEMORY_BITS` | `natural` | 12 | A `BOOT_MEMORY` ocupa $[0, 2^{BOOT\_MEMORY\_BITS})$ |
| `BOOT_MEMORY_BASE` | `map_addr_t` | `0` | Base da `BOOT_MEMORY`, sempre o endereço 0 |
| `BOOT_MEMORY_END` | `map_addr_t` | `0x1000` | Fim exclusivo da `BOOT_MEMORY`, $2^{BOOT\_MEMORY\_BITS}$ |
| `FLASH_BASE` | `map_addr_t` | `0x1000` | Base da FLASH, logo depois da `BOOT_MEMORY` |
| `FLASH_END` | `map_addr_t` | `0x8000` | Fim exclusivo da FLASH |
| `RAM_BASE` | `map_addr_t` | `0x8000` | Base da RAM |
| `RAM_END` | `map_addr_t` | `0x40000000` | Fim exclusivo da RAM |

### 2.6. Constantes compostas

| Constante | Definição |
| :--- | :--- |
| `HAS_MULTIPLICATION` | `HAS_M` ou `HAS_ZMMUL` |
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
| `HAS_INTERRUPTS` implica `HAS_ZICSR` | `Interrupcoes exigem Zicsr` |
| `HAS_SSCOFPMF` implica `HAS_ZIHPM` e `HAS_INTERRUPTS` | `Sscofpmf exige Zihpm e interrupcoes` |
| `HAS_ACCESS_FAULTS` implica `HAS_ZICSR` | `Falhas de acesso exigem Zicsr` |
| $16 \le ADDR\_BITS \le 64$ | `ADDR_BITS fora de 16..64` |
| $ADDR\_BITS \le XLEN$ | `ADDR_BITS maior que XLEN` |
| $BOOT\_MEMORY\_BITS < ADDR\_BITS$ | `BOOT_MEMORY_BITS deve ser menor que ADDR_BITS` |
| $BOOT\_MEMORY\_BASE = 0$ | `A BOOT_MEMORY deve comecar no endereco 0` |
| $BOOT\_MEMORY\_END \le FLASH\_BASE$ | `A memoria de instruções deve comecar depois da BOOT_MEMORY` |
| $FLASH\_BASE < FLASH\_END$ | `A FLASH deve ter tamanho positivo` |
| $FLASH\_END \le RAM\_BASE$ | `A memoria de instruções deve terminar antes da RAM` |
| $RAM\_BASE < RAM\_END$ | `A RAM deve ter tamanho positivo` |
| $RAM\_END \le 2^{ADDR\_BITS}$ | `A RAM deve caber no espaço de endereços fisico` |
| `HAS_ICACHE` implica `FLASH_ON_BUS` | `Cache de instruções exige FLASH_ON_BUS` |
| `HAS_DCACHE` implica `RAM_ON_BUS` | `Cache de dados exige RAM_ON_BUS` |

## 4. Verificação

O `config_pkg_tb` expõe as constantes como portas. O teste de entidade confere a configuração padrão e, com cópias do pacote de uma constante alterada, confere que cada condição de `check_isa` interrompe a elaboração. A prova formal troca o arquivo na lista de fontes por variantes (`IS_64` verdadeiro com `ADDR_BITS` 40, e base E) e prova as relações de largura e de mapa em cada uma.

## 5. Onde é usado

| Repositório | Arquivos |
| :--- | :--- |
| Common-Components | `counter64.vhd` e `tests/vhdl/config_pkg_tb.vhd` |

---

Copyright 2026 Insper. Licenciado sob a [Apache License, Version 2.0](../../../LICENSE).
