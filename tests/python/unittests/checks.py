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
