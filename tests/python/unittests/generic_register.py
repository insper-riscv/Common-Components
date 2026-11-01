"""Test generic_register: 8 bits, enable, asynchronous reset."""

import cocotb
from cocotb.triggers import RisingEdge, Timer

from tests.python.unittests.checks import check_equal
from tests.python.unittests.dut import Dut
from tests.python.unittests.harness import start_register


async def clock_in(dut: Dut, value: int, enable: int) -> int:
    """Apply the inputs for one edge and return o_d after it."""
    dut.i_d.value = value
    dut.i_enable.value = enable
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    return int(dut.o_d.value)


@cocotb.test()
async def test_stores_the_word_when_enabled(dut: Dut) -> None:
    """Store each word written with i_enable raised."""
    await start_register(dut)
    for value in (0xA5, 0x00, 0xFF, 0x3C):
        check_equal(await clock_in(dut, value, 1), value)


@cocotb.test()
async def test_holds_the_word_when_disabled(dut: Dut) -> None:
    """Hold the stored word while i_enable is low."""
    await start_register(dut)
    await clock_in(dut, 0x5A, 1)
    check_equal(await clock_in(dut, 0xFF, 0), 0x5A)


@cocotb.test()
async def test_reset_is_asynchronous(dut: Dut) -> None:
    """Clear the output without waiting for a clock edge."""
    await start_register(dut)
    await clock_in(dut, 0xFF, 1)
    dut.i_rst.value = 1
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0)
