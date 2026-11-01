"""Test mux_4x1: i_sel = n passes i_dn."""

import cocotb
from cocotb.triggers import Timer

from tests.python.unittests.checks import check_equal


@cocotb.test()
async def test_selects_each_input(dut):
    """Pass each of the four inputs in turn."""
    values = [0x11, 0x22, 0x33, 0x44]
    for i, v in enumerate(values):
        getattr(dut, f"i_d{i}").value = v
    for sel, expected in enumerate(values):
        dut.i_sel.value = sel
        await Timer(1, unit="ns")
        check_equal(int(dut.o_d.value), expected, sel)
