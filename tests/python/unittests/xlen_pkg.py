"""Test the widths of the four instances of xlen_pkg (xlen_pkg_tb)."""

import cocotb
from cocotb.triggers import Timer

from tests.python.unittests.checks import check_equal
from tests.python.unittests.dut import Dut

# Expected (word bits, register-index bits, register count).
EXPECTED = {
    "rv32i": (32, 5, 32),
    "rv32e": (32, 4, 16),
    "rv64i": (64, 5, 32),
    "rv64e": (64, 4, 16),
}


@cocotb.test()
async def test_instance_widths(dut: Dut) -> None:
    """Check word_t, reg_t and the register count of each instance."""
    await Timer(1, unit="ns")
    for name, (word, reg, regs) in EXPECTED.items():
        check_equal(int(getattr(dut, f"o_{name}_word").value), word, name)
        check_equal(int(getattr(dut, f"o_{name}_reg").value), reg, name)
        check_equal(int(getattr(dut, f"o_{name}_regs").value), regs, name)
