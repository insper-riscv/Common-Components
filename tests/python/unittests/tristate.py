"""Test tristate_buffer_1bit: drive when enabled, else 'Z'."""

import cocotb
from cocotb.triggers import Timer

from tests.python.unittests.checks import check_equal
from tests.python.unittests.dut import Dut


@cocotb.test()
async def test_tristate_drives_or_releases(dut: Dut) -> None:
    """Drive the data when enabled and release the line when not."""
    for data in (0, 1):
        dut.i_d.value = data
        dut.i_enable.value = 1
        await Timer(1, unit="ns")
        check_equal(str(dut.o_d.value), str(data), f"enabled, data={data}")
        dut.i_enable.value = 0
        await Timer(1, unit="ns")
        check_equal(str(dut.o_d.value), "Z", f"disabled, data={data}")
