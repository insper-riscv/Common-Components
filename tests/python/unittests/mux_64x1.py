"""Test mux_64x1: i_sel = n passes i_dn."""

import cocotb

from tests.python.unittests.dut import Dut
from tests.python.unittests.harness import check_each_input_selected


@cocotb.test()
async def test_selects_each_input(dut: Dut) -> None:
    """Pass each of the 64 inputs in turn."""
    await check_each_input_selected(
        dut, [(i * 5 + 3) & 0xFF for i in range(64)]
    )
