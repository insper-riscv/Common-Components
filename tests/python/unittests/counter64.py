"""Test counter64: two halves, registered carry, coherent read."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from tests.python.unittests.checks import check_equal
from tests.python.unittests.dut import Dut

MASK32 = 0xFFFFFFFF


async def start(dut: Dut) -> None:
    """Start the clock and release the reset after two edges."""
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_inc.value = 0
    dut.i_we_lo.value = 0
    dut.i_we_hi.value = 0
    dut.i_wdata.value = 0
    dut.i_rst.value = 1
    for _ in range(2):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    dut.i_rst.value = 0


def value(dut: Dut) -> int:
    """Return the 64-bit value shown by the two halves."""
    return (int(dut.o_hi.value) << 32) | int(dut.o_lo.value)


async def step(
    dut: Dut,
    inc: int = 0,
    we_lo: int | None = None,
    we_hi: int | None = None,
) -> int:
    """Apply one clock edge and return the 64-bit value after it."""
    dut.i_inc.value = inc
    dut.i_we_lo.value = int(we_lo is not None)
    dut.i_we_hi.value = int(we_hi is not None)
    dut.i_wdata.value = we_lo if we_lo is not None else (we_hi or 0)
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    dut.i_inc.value = 0
    dut.i_we_lo.value = 0
    dut.i_we_hi.value = 0
    return value(dut)


@cocotb.test()
async def test_reset_and_hold(dut: Dut) -> None:
    """Check the reset value and that the value holds without i_inc."""
    await start(dut)
    check_equal(value(dut), 0)
    for _ in range(3):
        check_equal(await step(dut), 0, "no increment without i_inc")


@cocotb.test()
async def test_counts_one_per_enabled_cycle(dut: Dut) -> None:
    """Check that each enabled cycle adds one."""
    await start(dut)
    for n in range(1, 20):
        check_equal(await step(dut, inc=1), n)


@cocotb.test()
async def test_the_read_is_coherent_across_the_carry(dut: Dut) -> None:
    """Check that the read is the ideal counter at every cycle."""
    await start(dut)
    await step(dut, we_lo=0xFFFFFFFD)
    await step(dut, we_hi=0x00000007)
    expected = (7 << 32) | 0xFFFFFFFD
    check_equal(value(dut), expected)
    for _ in range(6):
        expected += 1
        check_equal(await step(dut, inc=1), expected)
    check_equal(expected >> 32, 8)


@cocotb.test()
async def test_the_carry_crosses_idle_cycles(dut: Dut) -> None:
    """Check that a wrap followed by idle cycles sums the high half."""
    await start(dut)
    await step(dut, we_lo=MASK32)
    check_equal(await step(dut, inc=1), 1 << 32)
    for _ in range(3):
        check_equal(await step(dut), 1 << 32)


@cocotb.test()
async def test_a_write_wins_over_the_increment(dut: Dut) -> None:
    """Check that a write wins over the increment of the same cycle."""
    await start(dut)
    check_equal(await step(dut, inc=1, we_lo=0x1234), 0x1234)
    check_equal(await step(dut, inc=1, we_hi=0x55) >> 32, 0x55)
    check_equal((await step(dut, inc=1, we_lo=0x10)) & MASK32, 0x10)


@cocotb.test()
async def test_a_low_write_on_the_wrap_cycle_makes_no_carry(
    dut: Dut,
) -> None:
    """Check that a low write on the wrap cycle leaves no carry."""
    await start(dut)
    await step(dut, we_lo=MASK32)
    check_equal(await step(dut, inc=1, we_lo=0), 0)
    check_equal(await step(dut), 0)


@cocotb.test()
async def test_a_high_write_drops_the_pending_carry(dut: Dut) -> None:
    """Check that a high write discards the pending carry."""
    await start(dut)
    await step(dut, we_lo=MASK32)
    await step(dut, inc=1)  # Wraps: the carry is pending now.
    check_equal(value(dut), 1 << 32)
    check_equal(
        await step(dut, we_hi=0x20),
        0x20 << 32,
        "the write wins over the pending carry",
    )
    check_equal(await step(dut), 0x20 << 32)


@cocotb.test()
async def test_reset_clears_both_halves_and_the_carry(dut: Dut) -> None:
    """Check that the reset clears both halves and the carry."""
    await start(dut)
    await step(dut, we_lo=MASK32)
    await step(dut, inc=1)
    dut.i_rst.value = 1
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    dut.i_rst.value = 0
    check_equal(value(dut), 0)
    check_equal(await step(dut), 0)
