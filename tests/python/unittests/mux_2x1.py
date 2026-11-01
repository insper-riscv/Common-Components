"""Test mux_2x1: i_sel = n passes i_dn."""

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_selects_each_input(dut):
    """Pass each of the two inputs in turn."""
    dut.i_d0.value = 0x12
    dut.i_d1.value = 0x34
    for sel, expected in ((0, 0x12), (1, 0x34)):
        dut.i_sel.value = sel
        await Timer(1, unit="ns")
        assert int(dut.o_d.value) == expected, sel
