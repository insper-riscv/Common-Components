"""Typed view of the design under test that cocotb gives each test."""

from typing import Protocol

from cocotb.handle import LogicObject


class Dut(Protocol):
    """Design under test: every port is typed as a logic signal handle.

    cocotb passes a plain HierarchyObject, whose attribute access is
    typed as a generic handle with no `value` and that triggers such as
    RisingEdge do not accept. Annotating the `dut` parameter of a test
    with this protocol makes the ports read, write and trigger as the
    signals they are.
    """

    def __getattr__(self, name: str) -> LogicObject:
        """Return the port called `name`.

        Parameters
        ----------
        name : str
            Name of the port or internal signal.

        Returns
        -------
        LogicObject
            The signal handle.
        """
        ...
