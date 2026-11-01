"""Test onehot_decoder: input n raises only output bit n."""

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_raises_one_output_per_input(dut):
    """Raise exactly one of the eight outputs per input."""
    for n in range(8):
        dut.i_d.value = n
        await Timer(1, unit="ns")
        assert int(dut.o_d.value) == 1 << n, n
