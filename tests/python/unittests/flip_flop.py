"""Test flip_flop: enable-gated load, asynchronous reset."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from tests.python.unittests.checks import check_equal


async def start(dut):
    """Start the clock and release the reset after a pulse."""
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_rst.value = 1
    dut.i_enable.value = 0
    dut.i_d.value = 0
    await Timer(1, unit="ns")
    dut.i_rst.value = 0


@cocotb.test()
async def test_loads_only_when_enabled(dut):
    """Load i_d on the edge only while i_enable is raised."""
    await start(dut)
    dut.i_d.value = 1
    dut.i_enable.value = 0
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0, "loaded without the enable")
    dut.i_enable.value = 1
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 1)
    dut.i_d.value = 0
    dut.i_enable.value = 0
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 1, "lost the value without the enable")


@cocotb.test()
async def test_reset_is_asynchronous(dut):
    """Clear the output without waiting for a clock edge."""
    await start(dut)
    dut.i_d.value = 1
    dut.i_enable.value = 1
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 1)
    dut.i_rst.value = 1
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0, "reset needed a clock edge")
