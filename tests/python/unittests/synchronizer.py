"""Test synchronizer: o_d segue i_d após `stages` bordas, bit a bit."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from tests.python.unittests.checks import check_equal, check_true
from tests.python.unittests.dut import Dut


async def start(dut: Dut) -> None:
    """Start the clock with the reset low and the input at zero."""
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_rst.value = 0
    dut.i_d.value = 0
    await Timer(1, unit="ns")


@cocotb.test()
async def test_latency_is_the_number_of_stages(dut: Dut) -> None:
    """Mostra o valor novo em o_d na borda `stages`, e não antes."""
    await start(dut)
    stages = int(dut.stages.value)
    for _ in range(stages):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0)
    dut.i_d.value = 1
    for edge in range(1, stages + 1):
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ns")
        expected = 1 if edge == stages else 0
        got = int(dut.o_d.value)
        check_equal(got, expected, f"borda {edge}: o_d = {got}")


@cocotb.test()
async def test_falling_value_travels_too(dut: Dut) -> None:
    """Atravessa a descida com a mesma latência da subida."""
    await start(dut)
    stages = int(dut.stages.value)
    dut.i_d.value = 1
    for _ in range(stages + 1):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 1)
    dut.i_d.value = 0
    for _ in range(stages - 1):
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ns")
        check_equal(int(dut.o_d.value), 1)
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0)


@cocotb.test()
async def test_each_bit_is_independent(dut: Dut) -> None:
    """Atravessa os bits de um vetor sem misturá-los."""
    await start(dut)
    stages = int(dut.stages.value)
    width = int(dut.data_width.value)
    pattern = 0b1010101010101010 & ((1 << width) - 1)
    dut.i_d.value = pattern
    for _ in range(stages):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), pattern)


@cocotb.test()
async def test_a_one_cycle_pulse_is_not_lost(dut: Dut) -> None:
    """Entrega a o_d um pulso de um período de i_clk."""
    await start(dut)
    stages = int(dut.stages.value)
    await RisingEdge(dut.i_clk)
    dut.i_d.value = 1
    await RisingEdge(dut.i_clk)
    dut.i_d.value = 0
    seen: list[int] = []
    for _ in range(stages + 2):
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ns")
        seen.append(int(dut.o_d.value))
    check_true(sum(1 for v in seen if v) >= 1, f"o pulso se perdeu: {seen}")


@cocotb.test()
async def test_reset_clears_every_stage(dut: Dut) -> None:
    """Zera a saída na borda seguinte a i_rst = '1'."""
    await start(dut)
    stages = int(dut.stages.value)
    dut.i_d.value = int(dut.i_d.value) | 1
    for _ in range(stages + 1):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value) & 1, 1)
    dut.i_rst.value = 1
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(int(dut.o_d.value), 0, "o reset não zerou a cadeia")
    dut.i_rst.value = 0
    for _ in range(stages - 1):
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ns")
        check_equal(int(dut.o_d.value), 0)
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    check_equal(
        int(dut.o_d.value) & 1, 1, "a entrada não voltou depois do reset"
    )
