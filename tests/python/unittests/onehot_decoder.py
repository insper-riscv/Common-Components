"""onehot_decoder: a 3-bit input n raises exactly output bit n of 8."""

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_raises_one_output_per_input(dut):
    for n in range(8):
        dut.i_d.value = n
        await Timer(1, unit="ns")
        assert int(dut.o_d.value) == 1 << n, n
