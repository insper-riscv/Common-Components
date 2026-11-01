"""Test clearable_register with clear_value = '1' (fills with ones)."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from tests.python.unittests.checks import check_equal
from tests.python.unittests.dut import Dut


@cocotb.test()
async def test_clear_fills_with_ones(dut: Dut) -> None:
    """Fill the register with ones on clear, then write normally."""
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_enable.value = 1
    dut.i_d.value = 0x0000
    dut.i_clear.value = 1
    # The first edge may precede the applied values.
    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0xFFFF)
    dut.i_clear.value = 0
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0x0000, "the write after the clear failed")
