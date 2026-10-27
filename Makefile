SHELL := /bin/bash
GHDL  := ghdl
STD   := --std=08
WDIR  := build/ghdl
VHDL  := $(sort $(wildcard *.vhd))

.PHONY: check clean

# GHDL syntax check of every source, in dependency order (riscv-tools vhdl-sort, from a sibling checkout of Tests).
check:
	@mkdir -p $(WDIR)
	@$(GHDL) -a $(STD) --work=work --workdir=$(WDIR) $$(uv run --project ../Tests riscv-tools vhdl-sort $(VHDL))
	@echo "VHDL syntax check passed"

clean:
	rm -rf build
