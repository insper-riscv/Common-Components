"""Test config_pkg: widths, derived constants and check_isa.

The default configuration is read from the simulation of
config_pkg_tb. The invalid configurations are copies of the package with
one constant changed, elaborated with GHDL: check_isa must stop each of
them with an assertion failure.
"""

import re
import shutil
import subprocess
import tempfile
from pathlib import Path

import cocotb
from cocotb.triggers import Timer

from tests.python.unittests.checks import check_equal, check_true
from tests.python.unittests.dut import Dut

ROOT = Path(__file__).resolve().parents[3]
SOURCES = ("src/utils_pkg.vhd", "src/config_pkg.vhd")
TESTBENCH = "tests/vhdl/config_pkg_tb.vhd"

# Expected widths of the default configuration (RV32I, 32-bit address).
DEFAULT_WIDTHS = {
    "xlen": 32,
    "reg_bits": 5,
    "num_regs": 32,
    "addr_bits": 32,
    "word_len": 32,
    "reg_len": 5,
    "addr_len": 32,
    "map_len": 33,
}

# One invalid configuration per assertion of check_isa: the constant,
# its new value and the text the assertion must report.
INVALID = (
    ("HAS_ZIHPM", "true", "Zicntr e Zihpm exigem Zicsr"),
    ("HAS_ZICNTR", "true", "Zicntr e Zihpm exigem Zicsr"),
    ("HAS_INTERRUPTS", "true", "Interrupcoes exigem Zicsr"),
    ("HAS_SSCOFPMF", "true", "Sscofpmf exige Zihpm e interrupcoes"),
    ("HAS_ACCESS_FAULTS", "true", "Falhas de acesso exigem Zicsr"),
    ("ADDR_BITS", "40", "ADDR_BITS maior que XLEN"),
    ("ADDR_BITS", "8", "ADDR_BITS fora de 16..64"),
    ("ADDR_BITS", "65", "ADDR_BITS fora de 16..64"),
    ("BOOT_MEMORY_BITS", "32", "BOOT_MEMORY_BITS deve ser menor"),
    ("FLASH_BASE", 'x"00000800"', "deve comecar depois da BOOT_MEMORY"),
    ("FLASH_END", 'x"00001000"', "A FLASH deve ter tamanho positivo"),
    ("FLASH_END", 'x"00009000"', "deve terminar antes da RAM"),
    ("RAM_END", 'x"00008000"', "A RAM deve ter tamanho positivo"),
    ("HAS_ICACHE", "true", "exige FLASH_ON_BUS"),
    ("HAS_DCACHE", "true", "exige RAM_ON_BUS"),
)


def _set_constant(text: str, name: str, value: str) -> str:
    """Return text with the initial value of a constant replaced."""
    pattern = rf"(constant {name}\s*:\s*[^:]+?:= )([^;]*?)(;)"
    if name.endswith(("_END", "_BASE")) and name != "BOOT_MEMORY_BITS":
        pattern = rf"(constant {name}\s*:\s*map_addr_t := )([^;]*?)(;)"
        value = f"resize(unsigned'({value}), ADDR_BITS + 1)"
    new, count = re.subn(pattern, rf"\g<1>{value}\g<3>", text, count=1)
    check_equal(count, 1, name)
    return new


def _elaborate(overrides: tuple[tuple[str, str], ...]) -> tuple[int, str]:
    """Elaborate the testbench with the overrides, return the status."""
    ghdl = shutil.which("ghdl")
    check_true(ghdl is not None, "ghdl not found")
    text = (ROOT / SOURCES[1]).read_text(encoding="utf-8")
    for name, value in overrides:
        text = _set_constant(text, name, value)
    with tempfile.TemporaryDirectory() as work:
        variant = Path(work) / "config_pkg.vhd"
        variant.write_text(text, encoding="utf-8")
        files = [str(ROOT / SOURCES[0]), str(variant), str(ROOT / TESTBENCH)]
        base = [str(ghdl), "--std=08", f"--workdir={work}"]
        for command in (
            [*base[:1], "-a", *base[1:], *files],
            [*base[:1], "-e", *base[1:], "config_pkg_tb"],
            [*base[:1], "-r", *base[1:], "config_pkg_tb", "--stop-time=1ns"],
        ):
            done = subprocess.run(  # noqa: S603
                command, capture_output=True, text=True, check=False
            )
            if done.returncode != 0:
                return done.returncode, done.stdout + done.stderr
    return 0, ""


@cocotb.test()
async def test_default_widths(dut: Dut) -> None:
    """Check XLEN, REG_BITS, NUM_REGS, ADDR_BITS and the subtypes."""
    await Timer(1, unit="ns")
    for name, expected in DEFAULT_WIDTHS.items():
        check_equal(int(getattr(dut, f"o_{name}").value), expected, name)
    check_equal(int(dut.o_is_64.value), 0)
    check_equal(int(dut.o_is_e.value), 0)
    check_equal(int(dut.o_isa_ok.value), 1)


@cocotb.test()
async def test_default_relations(dut: Dut) -> None:
    """Check XLEN, NUM_REGS and REG_BITS against IS_64 and IS_E."""
    await Timer(1, unit="ns")
    xlen = int(dut.o_xlen.value)
    check_equal(xlen, 64 if int(dut.o_is_64.value) else 32)
    reg_bits = int(dut.o_reg_bits.value)
    check_equal(reg_bits, 4 if int(dut.o_is_e.value) else 5)
    check_equal(int(dut.o_num_regs.value), 2**reg_bits)
    check_equal(int(dut.o_word_len.value), xlen)
    check_equal(int(dut.o_map_len.value), int(dut.o_addr_bits.value) + 1)


@cocotb.test()
async def test_default_composites_and_map(dut: Dut) -> None:
    """Check the composite constants and the default memory map."""
    await Timer(1, unit="ns")
    check_equal(int(dut.o_has_multiplication.value), 0)
    check_equal(int(dut.o_has_any_counter.value), 0)
    check_equal(int(dut.o_has_sscof.value), 0)
    expected = {
        "boot_end": 0x1000,
        "flash_base": 0x1000,
        "flash_end": 0x8000,
        "ram_base": 0x8000,
        "ram_end": 0x40000000,
    }
    for name, value in expected.items():
        check_equal(int(getattr(dut, f"o_{name}").value), value, name)


@cocotb.test()
async def test_isa_string(dut: Dut) -> None:
    """Check the name of the default ISA."""
    await Timer(1, unit="ns")
    raw = int(dut.o_isa.value).to_bytes(16, "big")
    check_equal(raw.decode("ascii").strip(), "rv32i_zicclsm")


@cocotb.test()
async def test_valid_variant_elaborates(dut: Dut) -> None:
    """Check that a valid RV64 configuration passes check_isa."""
    del dut
    status, output = _elaborate((("IS_64", "true"), ("ADDR_BITS", "40")))
    check_equal(status, 0, output)


@cocotb.test()
async def test_invalid_configurations_fail(dut: Dut) -> None:
    """Check that check_isa stops each invalid configuration."""
    del dut
    for name, value, message in INVALID:
        status, output = _elaborate(((name, value),))
        check_true(status != 0, f"{name}={value} was accepted")
        check_true(message in output, f"{name}={value}: {output}")


@cocotb.test()
async def test_cache_rules_accept_buses(dut: Dut) -> None:
    """Check that each cache elaborates with its memory on the bus."""
    del dut
    for overrides in (
        (("HAS_ICACHE", "true"), ("FLASH_ON_BUS", "true")),
        (("HAS_DCACHE", "true"), ("RAM_ON_BUS", "true")),
        (
            ("HAS_ICACHE", "true"),
            ("FLASH_ON_BUS", "true"),
            ("HAS_DCACHE", "true"),
            ("RAM_ON_BUS", "true"),
        ),
        (("FLASH_ON_BUS", "true"), ("RAM_ON_BUS", "true")),
    ):
        status, output = _elaborate(overrides)
        check_equal(status, 0, output)
