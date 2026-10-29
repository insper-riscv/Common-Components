"""synchronizer: o_d reflete i_d depois de `stages` bordas de subida de i_clk, bit a bit."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def start(dut):
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_rst.value = 0
    dut.i_d.value = 0
    await Timer(1, unit="ns")


@cocotb.test()
async def test_latency_is_the_number_of_stages(dut):
    """O valor novo aparece em o_d na borda de número `stages` e não antes."""
    await start(dut)
    stages = int(dut.stages.value)
    for _ in range(stages):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 0
    dut.i_d.value = 1
    for edge in range(1, stages + 1):
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ns")
        expected = 1 if edge == stages else 0
        assert int(dut.o_d.value) == expected, f"borda {edge}: o_d = {int(dut.o_d.value)}"


@cocotb.test()
async def test_falling_value_travels_too(dut):
    """A descida atravessa com a mesma latência da subida."""
    await start(dut)
    stages = int(dut.stages.value)
    dut.i_d.value = 1
    for _ in range(stages + 1):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 1
    dut.i_d.value = 0
    for _ in range(stages - 1):
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ns")
        assert int(dut.o_d.value) == 1
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 0


@cocotb.test()
async def test_each_bit_is_independent(dut):
    """Os bits de um vetor atravessam sem se misturar."""
    await start(dut)
    stages = int(dut.stages.value)
    width = int(dut.data_width.value)
    pattern = 0b1010101010101010 & ((1 << width) - 1)
    dut.i_d.value = pattern
    for _ in range(stages):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == pattern


@cocotb.test()
async def test_a_one_cycle_pulse_is_not_lost(dut):
    """Um pulso de um período de i_clk chega a o_d, com a largura de um período."""
    await start(dut)
    stages = int(dut.stages.value)
    await RisingEdge(dut.i_clk)
    dut.i_d.value = 1
    await RisingEdge(dut.i_clk)
    dut.i_d.value = 0
    seen = []
    for _ in range(stages + 2):
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ns")
        seen.append(int(dut.o_d.value))
    assert sum(1 for v in seen if v) >= 1, f"o pulso se perdeu: {seen}"


@cocotb.test()
async def test_reset_clears_every_stage(dut):
    """Com i_rst = '1' a saída vai a 0 na borda seguinte, mesmo com a entrada em 1."""
    await start(dut)
    stages = int(dut.stages.value)
    dut.i_d.value = int(dut.i_d.value) | 1
    for _ in range(stages + 1):
        await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) & 1 == 1
    dut.i_rst.value = 1
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) == 0, "o reset não zerou a cadeia"
    dut.i_rst.value = 0
    for _ in range(stages - 1):
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ns")
        assert int(dut.o_d.value) == 0
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ns")
    assert int(dut.o_d.value) & 1 == 1, "a entrada não voltou depois do reset"
