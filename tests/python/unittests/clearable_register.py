"""Test clearable_register: synchronous clear, priority over write."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from tests.python.unittests.checks import check_equal
from tests.python.unittests.dut import Dut


async def start(dut: Dut) -> None:
    """Start the clock and clear the register."""
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_clear.value = 1
    dut.i_enable.value = 0
    dut.i_d.value = 0
    await RisingEdge(dut.i_clk)
    dut.i_clear.value = 0
    await Timer(1, unit="ns")


async def clock_in(dut: Dut, value: int, enable: int, clear: int) -> int:
    """Apply the inputs for one edge and return o_d after it."""
    dut.i_d.value = value
    dut.i_enable.value = enable
    dut.i_clear.value = clear
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    return int(dut.o_d.value)


@cocotb.test()
async def test_writes_only_when_enabled(dut: Dut) -> None:
    """Write on the edge only while i_enable is raised."""
    await start(dut)
    check_equal(await clock_in(dut, 0xABCD, 1, 0), 0xABCD)
    check_equal(await clock_in(dut, 0x1111, 0, 0), 0xABCD)


@cocotb.test()
async def test_clear_needs_a_clock_edge_and_beats_the_write(
    dut: Dut,
) -> None:
    """Clear on the edge only, winning over a simultaneous write."""
    await start(dut)
    await clock_in(dut, 0xFFFF, 1, 0)
    dut.i_clear.value = 1
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0xFFFF, "cleared before the edge")
    result = await clock_in(dut, 0x1234, 1, 1)
    check_equal(result, 0, "the write won over the clear")
