"""Shared helpers for the cocotb tests."""


def check_equal(
    actual: object, expected: object, message: object = ""
) -> None:
    """Raise AssertionError when actual differs from expected."""
    if actual != expected:
        raise AssertionError(f"{actual!r} != {expected!r}: {message}")


def check_true(condition: object, message: object = "") -> None:
    """Raise AssertionError when condition is false."""
    if not condition:
        raise AssertionError(message)


def pseudo_random(seed: int, count: int, bits: int) -> list[int]:
    """Return count deterministic integers of the given bit width.

    A xorshift64 generator, so the vectors are reproducible without
    pulling in a cryptographically unsuitable `random` generator.
    """
    state = seed or 1
    mask64 = (1 << 64) - 1
    values: list[int] = []
    for _ in range(count):
        state ^= (state << 13) & mask64
        state ^= state >> 7
        state ^= (state << 17) & mask64
        values.append(state & ((1 << bits) - 1))
    return values


class Prng:
    """Deterministic xorshift64 generator for reproducible stimuli."""

    def __init__(self, seed: int) -> None:
        """Start the sequence from a seed."""
        self.state = (seed & ((1 << 64) - 1)) or 1

    def getrandbits(self, bits: int) -> int:
        """Return an integer of the given bit width."""
        mask64 = (1 << 64) - 1
        self.state ^= (self.state << 13) & mask64
        self.state ^= self.state >> 7
        self.state ^= (self.state << 17) & mask64
        return (self.state >> (64 - bits)) if bits else 0

    def choice(self, sequence: tuple[int, ...]) -> int:
        """Return one element of the sequence."""
        return sequence[self.getrandbits(32) % len(sequence)]
