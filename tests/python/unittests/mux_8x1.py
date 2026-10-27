"""mux_8x1: i_sel = n passes i_dn."""

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_selects_each_input(dut):
    values = [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]
    for i, v in enumerate(values):
        getattr(dut, f"i_d{i}").value = v
    for sel, expected in enumerate(values):
        dut.i_sel.value = sel
        await Timer(1, unit="ns")
        assert int(dut.o_d.value) == expected, sel
