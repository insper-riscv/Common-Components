"""Test the combinational functions of utils_pkg (via utils_pkg_tb)."""

import random

import cocotb
from cocotb.triggers import Timer


async def apply(dut, a, b=0):
    """Apply both operands and wait for the outputs to settle."""
    dut.i_a.value = a
    dut.i_b.value = b
    await Timer(1, unit="ns")


def reverse8(value):
    """Return value with its 8 bits in reverse order."""
    return int(format(value, "08b")[::-1], 2)


@cocotb.test()
async def test_reverse_vector(dut):
    """Reverse the bit order of an 8-bit vector."""
    for a in (0x00, 0x01, 0x80, 0xA5, 0xFF, 0x12):
        await apply(dut, a)
        assert int(dut.o_reverse.value) == reverse8(a), hex(a)


@cocotb.test()
async def test_reductions(dut):
    """Reduce an 8-bit vector with OR and with AND."""
    for a in (0x00, 0x01, 0x80, 0xFF, 0x7F, 0xFE, 0x55):
        await apply(dut, a)
        assert int(dut.o_reduce_or.value) == int(a != 0), hex(a)
        assert int(dut.o_reduce_and.value) == int(a == 0xFF), hex(a)


@cocotb.test()
async def test_comparisons(dut):
    """Compare corner and seeded random pairs of 8-bit operands."""
    rng = random.Random(3)
    pairs = [(0, 0), (0xFF, 0xFF), (0xFF, 0xFE), (0x80, 0x00), (1, 3)]
    pairs += [(rng.getrandbits(8), rng.getrandbits(8)) for _ in range(100)]
    for a, b in pairs:
        await apply(dut, a, b)
        assert int(dut.o_equal_dyn.value) == int(a == b), (hex(a), hex(b))
        assert int(dut.o_equals.value) == int(a == b), (hex(a), hex(b))
        assert int(dut.o_not_equals.value) == int(a != b), (hex(a), hex(b))
