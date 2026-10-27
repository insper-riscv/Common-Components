"""flip_flop: loads i_d on a rising edge when i_enable = '1'; i_rst = '1' clears it asynchronously."""

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


@cocotb.test()
async def test_loads_only_when_enabled(dut):
    await start(dut)
    dut.i_d.value = 1
    dut.i_enable.value = 0
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 0, "loaded without the enable"
    dut.i_enable.value = 1
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 1
    dut.i_d.value = 0
    dut.i_enable.value = 0
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 1, "lost the value without the enable"


@cocotb.test()
async def test_reset_is_asynchronous(dut):
    await start(dut)
    dut.i_d.value = 1
    dut.i_enable.value = 1
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 1
    dut.i_rst.value = 1
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 0, "reset needed a clock edge"
