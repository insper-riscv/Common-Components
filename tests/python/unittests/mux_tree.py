"""Test mux_tree (via mux_tree_tb): i_sel = n passes word n."""

import cocotb
from cocotb.triggers import Timer

from tests.python.unittests.checks import check_equal

WORDS = [0x3, 0xA, 0x5, 0xF, 0x0, 0x9, 0x6, 0xC]


@cocotb.test()
async def test_selects_each_word(dut):
    """Pass each of the eight 4-bit words in turn."""
    dut.i_flat.value = sum(w << (4 * i) for i, w in enumerate(WORDS))
    for sel, expected in enumerate(WORDS):
        dut.i_sel.value = sel
        await Timer(1, unit="ns")
        check_equal(int(dut.o_d.value), expected, sel)
