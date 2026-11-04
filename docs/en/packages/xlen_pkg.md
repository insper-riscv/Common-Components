# xlen_pkg

🌐 [Português](../../pt-br/packages/xlen_pkg.md) · [English](../../en/packages/xlen_pkg.md)

## 1. Purpose

VHDL-2008 generic package that fixes, at instantiation, the data width and the register index width. Whoever uses it instantiates the package once with the values of its profile and gains the `word_t` and `reg_t` subtypes.

## 2. Declarations

| Declaration | Kind | Description |
| :--- | :--- | :--- |
| `xlen` | generic natural, default 32 | Width in bits of data, PC and registers. Only 32 and 64 are valid, and the instantiating entity checks the value with an `assert`, since a package does not run assertions. |
| `rve` | generic boolean, default `false` | True for the E base, with a 4-bit register index, and false for the I base, with 5 bits. |
| `WORD_BITS` | constant | Equal to `xlen`. |
| `REG_ADDR_BITS` | constant | Register index width, $5 - [rve]$. |
| `NUM_REGS` | constant | Number of general-purpose registers, $2^{REG\_ADDR\_BITS}$. |
| `word_t` | subtype | `std_logic_vector(WORD_BITS-1 downto 0)`. |
| `reg_t` | subtype | `std_logic_vector(REG_ADDR_BITS-1 downto 0)`. |

## 3. Behavior

The instantiation has the form

```vhdl
package isa_p is new work.xlen_pkg generic map (xlen => 64, rve => false);
```

and the constants derive from the two generics.

$$WORD\_BITS = xlen, \qquad REG\_ADDR\_BITS = 5 - [rve], \qquad NUM\_REGS = 2^{REG\_ADDR\_BITS}$$

The I base (`rve` false) yields 32 registers and the E base (`rve` true) yields 16.

## 4. Where it is used

| Repository | Files |
| :--- | :--- |
| Common-Components | `tests/vhdl/xlen_pkg_tb.vhd`, the only instantiator of the package |

---

Copyright 2026 Insper. Licensed under the [Apache License, Version 2.0](../../../LICENSE).
