"""Test mux_tree (via mux_tree_tb): i_sel = n passes word n, for any stage_bits."""

import cocotb
from cocotb.triggers import Timer

from tests.python.unittests.checks import check_equal
from tests.python.unittests.dut import Dut


def make_words(count: int, width: int) -> list[int]:
    """Return count words of the given width, all different when they fit.

    The step 37 is odd, so i * 37 + 11 is a bijection modulo any power of
    two: with 2**width >= count no two words are equal, and a wrong path
    through the tree cannot go unnoticed.
    """
    mask = (1 << width) - 1
    return [(i * 37 + 11) & mask for i in range(count)]


@cocotb.test()
async def test_selects_each_word(dut: Dut) -> None:
    """Sweep the whole selector and pass every word in turn."""
    width = len(dut.o_d)
    words = make_words(1 << len(dut.i_sel), width)
    dut.i_flat.value = sum(w << (width * i) for i, w in enumerate(words))
    for sel, expected in enumerate(words):
        dut.i_sel.value = sel
        await Timer(1, unit="ns")
        check_equal(int(dut.o_d.value), expected, sel)


@cocotb.test()
async def test_follows_data_change(dut: Dut) -> None:
    """Change the words under a fixed selector and follow the new word."""
    width = len(dut.o_d)
    count = 1 << len(dut.i_sel)
    mask = (1 << width) - 1
    for sel in (0, count - 1, count // 2):
        dut.i_sel.value = sel
        for offset in (5, 91):
            words = [(w + offset) & mask for w in make_words(count, width)]
            dut.i_flat.value = sum(
                w << (width * i) for i, w in enumerate(words)
            )
            await Timer(1, unit="ns")
            check_equal(int(dut.o_d.value), words[sel], (sel, offset))
