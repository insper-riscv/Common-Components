"""Test mux_4x1: i_sel = n passes i_dn."""

import cocotb

from tests.python.unittests.dut import Dut
from tests.python.unittests.harness import check_each_input_selected


@cocotb.test()
async def test_selects_each_input(dut: Dut) -> None:
    """Pass each of the four inputs in turn."""
    await check_each_input_selected(dut, [0x11, 0x22, 0x33, 0x44])
