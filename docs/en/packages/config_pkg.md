# config_pkg

🌐 [Português](../../pt-br/packages/config_pkg.md) · [English](../../en/packages/config_pkg.md)

## 1. Purpose

Package of elaboration constants that mirrors, in VHDL, the configuration chosen by `platform.yaml`: the ISA base, the physical address width, the extensions, the caches and the memory map in bytes. Every module reads the constants and uses `generate` on them, so a disabled extension generates no logic. The package types `word_t`, `reg_t`, `addr_t` and `map_addr_t` are the data, register index and address types of every module.

Common-Components ships the package with the default values (RV32I with Zicclsm, 32-bit address, no peripherals), which the module tests use. A platform top and the formal proofs swap this file, in the source list, for a generated version with the same unit name and the same constants. The package is not generic because Quartus Prime Lite rejects generic packages.

## 2. Parameters

Each parameter is a constant of the package. The value column shows the default of this repository.

### 2.1. Base and width

| Constant | Type | Default | Range | Meaning |
| :--- | :--- | :--- | :--- | :--- |
| `IS_64` | `boolean` | `false` | | 64-bit base (RV64) when true, 32-bit base (RV32) when false |
| `IS_E` | `boolean` | `false` | | E base, with 16 registers, when true; I base, with 32, when false |
| `ADDR_BITS` | `natural` | 32 | 16 to 64, above 32 only with `IS_64` | Width of the physical address, in bits |
| `XLEN` | `natural` | 32 | 32 or 64 | Width of the data word, the logical PC and the registers, derived from `IS_64` |
| `REG_BITS` | `natural` | 5 | 4 or 5 | Width of the register index, derived from `IS_E` |
| `NUM_REGS` | `natural` | 32 | 16 or 32 | Number of general-purpose registers, $2^{REG\_BITS}$ |

$$XLEN = \begin{cases} 64 & IS\_64 \\ 32 & \text{otherwise} \end{cases} \qquad REG\_BITS = \begin{cases} 4 & IS\_E \\ 5 & \text{otherwise} \end{cases}$$

### 2.2. Subtypes

| Subtype | Definition | Description |
| :--- | :--- | :--- |
| `word_t` | `std_logic_vector(XLEN-1 downto 0)` | Data word |
| `reg_t` | `std_logic_vector(REG_BITS-1 downto 0)` | Register index |
| `addr_t` | `std_logic_vector(ADDR_BITS-1 downto 0)` | Physical address |
| `map_addr_t` | `unsigned(ADDR_BITS downto 0)` | Map address in bytes, with one extra bit to represent the exclusive end $2^{ADDR\_BITS}$ |

### 2.3. Extensions and core options

All are `boolean`. The default is true for `HAS_ZICCLSM` and false for the others.

| Constant | Meaning | Requires |
| :--- | :--- | :--- |
| `HAS_M` | Multiplication and division; with it, `HAS_ZMMUL` is ignored | |
| `HAS_ZMMUL` | Multiplication only | |
| `HAS_ZICSR` | Zicsr and machine-mode exception handling | |
| `HAS_ZICNTR` | `mcycle`, `minstret` and `time` counters | `HAS_ZICSR` |
| `HAS_ZIHPM` | Event counters | `HAS_ZICSR` |
| `HAS_ZIMOP` | `mop.r.n` and `mop.rr.n` | |
| `HAS_ZICOND` | `czero.eqz` and `czero.nez` | |
| `HAS_ZIHINTNTL` | `ntl.*` hints | |
| `HAS_ZIHINTPAUSE` | `pause` hint | |
| `HAS_ZIFENCEI` | `fence.i` | |
| `HAS_ZICCLSM` | Misaligned access to main memory in hardware | |
| `HAS_INTERRUPTS` | Machine interrupts (`mip` and `mie`) | `HAS_ZICSR` |
| `HAS_SSCOFPMF` | Event counter overflow | `HAS_ZIHPM` and `HAS_INTERRUPTS` |
| `HAS_ACCESS_FAULTS` | Access faults (causes 1, 5 and 7) outside the valid map | `HAS_ZICSR` |

### 2.4. Memory system

An access to a region follows the region itself: the `BOOT_MEMORY` is always direct, the FLASH and the RAM are direct or on the bus according to `FLASH_ON_BUS` and `RAM_ON_BUS`, and everything else goes on the bus. The region only selects the cache.

| Constant | Type | Default | Meaning | Requires |
| :--- | :--- | :--- | :--- | :--- |
| `FLASH_ON_BUS` | `boolean` | `false` | The FLASH is reached through the bus (true) or through the direct port of the core (false) | |
| `RAM_ON_BUS` | `boolean` | `false` | The RAM is reached through the bus (true) or through the direct port of the core (false) | |
| `HAS_ICACHE` | `boolean` | `false` | Instruction cache | `FLASH_ON_BUS` |
| `HAS_DCACHE` | `boolean` | `false` | Data cache | `RAM_ON_BUS` |
| `I_CACHE_WINDOW_BITS` | `natural` | 12 | Width in bits of the address window of the instruction cache (12 = 4 KiB) | |
| `D_CACHE_WINDOW_BITS` | `natural` | 12 | Width in bits of the address window of the data cache (12 = 4 KiB) | |

### 2.5. Memory map

Addresses are `map_addr_t`, in bytes. The map is increasing and fits in the space of $2^{ADDR\_BITS}$ bytes.

| Constant | Type | Default | Meaning |
| :--- | :--- | :--- | :--- |
| `BOOT_MEMORY_BITS` | `natural` | 12 | The `BOOT_MEMORY` occupies $[0, 2^{BOOT\_MEMORY\_BITS})$ |
| `BOOT_MEMORY_BASE` | `map_addr_t` | `0` | Base of the `BOOT_MEMORY`, always address 0 |
| `BOOT_MEMORY_END` | `map_addr_t` | `0x1000` | Exclusive end of the `BOOT_MEMORY`, $2^{BOOT\_MEMORY\_BITS}$ |
| `FLASH_BASE` | `map_addr_t` | `0x1000` | Base of the FLASH, right after the `BOOT_MEMORY` |
| `FLASH_END` | `map_addr_t` | `0x8000` | Exclusive end of the FLASH |
| `RAM_BASE` | `map_addr_t` | `0x8000` | Base of the RAM |
| `RAM_END` | `map_addr_t` | `0x40000000` | Exclusive end of the RAM |

### 2.6. Peripherals that interact with the core

All constants are `boolean` and default to `false`: `HAS_GPIO`, `HAS_CLINT`, `HAS_PLIC` and `HAS_TIMER`. Peripheral addresses are not part of the package: they belong to the map package of each platform.

### 2.7. Composite constants

| Constant | Definition |
| :--- | :--- |
| `HAS_MULTIPLICATION` | `HAS_M` or `HAS_ZMMUL` |
| `HAS_ANY_COUNTER` | `HAS_ZICNTR` or `HAS_ZIHPM` |
| `HAS_SSCOF` | `HAS_SSCOFPMF`, `HAS_ZIHPM` and `HAS_INTERRUPTS` |

## 3. Functions

| Function | Return | Description |
| :--- | :--- | :--- |
| `isa_string` | `string` | Name of the configured ISA in the canonical order of the extensions, such as `rv32im_zicclsm` |
| `check_isa` | `boolean` | Checks the dependencies and ranges below, fails the elaboration with `severity failure` when one does not hold, and returns `true` |

The top entity of the chain calls `check_isa` once, in the `generate` (`if check_isa generate`), and prints `isa_string` in a `report`. The call is not placed in a constant of the package, because GHDL warns that the function is called before its body is elaborated.

Conditions that `check_isa` requires.

| Condition | Failure message |
| :--- | :--- |
| `HAS_ZICNTR` or `HAS_ZIHPM` imply `HAS_ZICSR` | `Zicntr e Zihpm exigem Zicsr` |
| `HAS_INTERRUPTS` implies `HAS_ZICSR` | `Interrupcoes exigem Zicsr` |
| `HAS_SSCOFPMF` implies `HAS_ZIHPM` and `HAS_INTERRUPTS` | `Sscofpmf exige Zihpm e interrupcoes` |
| `HAS_ACCESS_FAULTS` implies `HAS_ZICSR` | `Falhas de acesso exigem Zicsr` |
| $16 \le ADDR\_BITS \le 64$ | `ADDR_BITS fora de 16..64` |
| $ADDR\_BITS > 32$ implies `IS_64` | `ADDR_BITS > 32 exige IS_64` |
| $BOOT\_MEMORY\_BITS < ADDR\_BITS$ | `BOOT_MEMORY_BITS deve ser menor que ADDR_BITS` |
| $BOOT\_MEMORY\_BASE = 0$ | `A BOOT_MEMORY deve comecar no endereco 0` |
| $BOOT\_MEMORY\_END \le FLASH\_BASE$ | `A memoria de instruções deve comecar depois da BOOT_MEMORY` |
| $FLASH\_BASE < FLASH\_END$ | `A FLASH deve ter tamanho positivo` |
| $FLASH\_END \le RAM\_BASE$ | `A memoria de instruções deve terminar antes da RAM` |
| $RAM\_BASE < RAM\_END$ | `A RAM deve ter tamanho positivo` |
| $RAM\_END \le 2^{ADDR\_BITS}$ | `A RAM deve caber no espaço de endereços fisico` |
| `HAS_ICACHE` implies `FLASH_ON_BUS` | `Cache de instruções exige FLASH_ON_BUS` |
| `HAS_DCACHE` implies `RAM_ON_BUS` | `Cache de dados exige RAM_ON_BUS` |

## 4. Verification

`config_pkg_tb` exposes the constants as ports. The entity test checks the default configuration and, with copies of the package that change one constant, checks that each condition of `check_isa` stops the elaboration. The formal proof swaps the file in the source list for variants (`IS_64` true with `ADDR_BITS` 40, and the E base) and proves the width and map relations in each.

## 5. Where it is used

| Repository | Files |
| :--- | :--- |
| Common-Components | `counter64.vhd` and `tests/vhdl/config_pkg_tb.vhd` |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
