"""Setup and check sequences shared by several entity tests."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer

from tests.python.unittests.checks import check_equal
from tests.python.unittests.dut import Dut


async def start_register(dut: Dut) -> None:
    """Start the clock and release the reset after a pulse."""
    cocotb.start_soon(Clock(dut.i_clk, 10, unit="ns").start())
    dut.i_rst.value = 1
    dut.i_enable.value = 0
    dut.i_d.value = 0
    await Timer(1, unit="ns")
    dut.i_rst.value = 0


async def check_each_input_selected(dut: Dut, values: list[int]) -> None:
    """Drive i_d0..i_dn with values and check i_sel = n passes i_dn."""
    for i, v in enumerate(values):
        getattr(dut, f"i_d{i}").value = v
    for sel, expected in enumerate(values):
        dut.i_sel.value = sel
        await Timer(1, unit="ns")
        check_equal(int(dut.o_d.value), expected, sel)
