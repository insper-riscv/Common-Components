"""adder: o_d = (i_a + i_b) mod 2**32."""

import random

import cocotb
from cocotb.triggers import Timer

MASK = (1 << 32) - 1


async def add(dut, a, b):
    dut.i_a.value = a
    dut.i_b.value = b
    await Timer(1, unit="ns")
    return int(dut.o_d.value)


@cocotb.test()
async def test_sums_and_wraps_around(dut):
    for a, b in [(0, 0), (1, 2), (0xFFFFFFFF, 1), (0x80000000, 0x80000000), (0xFFFFFFFF, 0xFFFFFFFF)]:
        assert await add(dut, a, b) == (a + b) & MASK, (hex(a), hex(b))


@cocotb.test()
async def test_random_operands(dut):
    rng = random.Random(7)
    for _ in range(200):
        a, b = rng.getrandbits(32), rng.getrandbits(32)
        assert await add(dut, a, b) == (a + b) & MASK, (hex(a), hex(b))
