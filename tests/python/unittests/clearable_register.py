"""clearable_register: synchronous clear (to zeros) with priority over the write, plus enable."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def start(dut):
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_clear.value = 1
    dut.i_enable.value = 0
    dut.i_d.value = 0
    await RisingEdge(dut.i_clk)
    dut.i_clear.value = 0
    await Timer(1, unit="ns")


async def clock_in(dut, value, enable, clear):
    dut.i_d.value = value
    dut.i_enable.value = enable
    dut.i_clear.value = clear
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    return int(dut.o_d.value)


@cocotb.test()
async def test_writes_only_when_enabled(dut):
    await start(dut)
    assert await clock_in(dut, 0xABCD, 1, 0) == 0xABCD
    assert await clock_in(dut, 0x1111, 0, 0) == 0xABCD


@cocotb.test()
async def test_clear_needs_a_clock_edge_and_beats_the_write(dut):
    await start(dut)
    await clock_in(dut, 0xFFFF, 1, 0)
    dut.i_clear.value = 1
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 0xFFFF, "cleared before the edge"
    assert await clock_in(dut, 0x1234, 1, 1) == 0, "the write won over the clear"
