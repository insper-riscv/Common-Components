"""Test adder: o_d = (i_a + i_b) mod 2**32."""

import cocotb
from cocotb.triggers import Timer

from tests.python.unittests.checks import check_equal, pseudo_random
from tests.python.unittests.dut import Dut

MASK = (1 << 32) - 1
CORNERS = [
    (0, 0),
    (1, 2),
    (0xFFFFFFFF, 1),
    (0x80000000, 0x80000000),
    (0xFFFFFFFF, 0xFFFFFFFF),
]


async def add(dut: Dut, a: int, b: int) -> int:
    """Apply both operands and return the sum read from o_d."""
    dut.i_a.value = a
    dut.i_b.value = b
    await Timer(1, unit="ns")
    return int(dut.o_d.value)


@cocotb.test()
async def test_sums_and_wraps_around(dut: Dut) -> None:
    """Sum the corner operands, wrapping around at 32 bits."""
    for a, b in CORNERS:
        check_equal(await add(dut, a, b), (a + b) & MASK, (hex(a), hex(b)))


@cocotb.test()
async def test_random_operands(dut: Dut) -> None:
    """Sum 200 seeded random operand pairs."""
    operands = pseudo_random(7, 400, 32)
    for a, b in zip(operands[::2], operands[1::2], strict=True):
        check_equal(await add(dut, a, b), (a + b) & MASK, (hex(a), hex(b)))
