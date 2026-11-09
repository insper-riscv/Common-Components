SHELL := /bin/bash
GHDL  := ghdl
STD   := --std=08
WDIR  := build/ghdl

VHDL := $(sort $(wildcard src/*.vhd))

.PHONY: check test paths formal clean

# GHDL syntax check of every source, in dependency order (riscv-tools vhdl-sort), and the ban on the
# minimum and maximum functions, which Quartus Lite refuses and GHDL accepts.
check:
	@mkdir -p $(WDIR)
	@$(GHDL) -a $(STD) --work=work --workdir=$(WDIR) $$(riscv-tools vhdl-sort $(VHDL))
	@if grep -nE '\b(minimum|maximum)[[:space:]]*\(' $(VHDL) | grep -v '^[^:]*:[0-9]*:[[:space:]]*--'; then \
		echo "minimum/maximum (VHDL-2008) is refused by Quartus Lite (error 10482): use a local function"; exit 1; fi
	@echo "VHDL syntax check passed"

# Per-entity cocotb tests; `make test TEST=Adder` for one entry of tests/python/tests.json.
test:
	uv run python tests/python/runner.py $(TEST)

# Every path the configuration lists exists.
paths:
	riscv-tools --root . check-paths --manifest paths.yaml
	riscv-tools --root . check-tree --kind common-components

# Formal proofs (SymbiYosys and one engine of the CI image: FORMAL_ENGINE is yices, bitwuzla, boolector or
# abc-bmc3): the synchronizer, flip_flop, generic_register, clearable_register, config_pkg and counter64 proofs
# with their mutants.
# The result of the run is build/formal/result-<engine>.tsv.
FORMAL_ENGINE ?= bitwuzla
formal:
	FORMAL_ENGINE=$(FORMAL_ENGINE) bash formal/run.sh

clean:
	rm -rf build
	find . -type f \( -name '*.vcd' -o -name '*.ghw' \) -print -delete
