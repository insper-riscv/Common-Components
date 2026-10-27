"""generic_register: an 8-bit register with enable and asynchronous reset."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def start(dut):
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_rst.value = 1
    dut.i_enable.value = 0
    dut.i_d.value = 0
    await Timer(1, unit="ns")
    dut.i_rst.value = 0


async def clock_in(dut, value, enable):
    dut.i_d.value = value
    dut.i_enable.value = enable
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    return int(dut.o_d.value)


@cocotb.test()
async def test_stores_the_word_when_enabled(dut):
    await start(dut)
    for value in (0xA5, 0x00, 0xFF, 0x3C):
        assert await clock_in(dut, value, 1) == value


@cocotb.test()
async def test_holds_the_word_when_disabled(dut):
    await start(dut)
    await clock_in(dut, 0x5A, 1)
    assert await clock_in(dut, 0xFF, 0) == 0x5A


@cocotb.test()
async def test_reset_is_asynchronous(dut):
    await start(dut)
    await clock_in(dut, 0xFF, 1)
    dut.i_rst.value = 1
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 0
