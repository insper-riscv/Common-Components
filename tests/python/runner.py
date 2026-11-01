"""Run the cocotb tests of tests.json, one simulation per entity."""

import argparse
import json
import os
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

# cocotb 2.0 moved the Python test-runner API out of the main cocotb
# package into cocotb-tools, imported as cocotb_tools.runner.
from cocotb_tools.check_results import get_results
from cocotb_tools.runner import get_runner

TESTS_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = Path(__file__).resolve().parents[2]
CONFIG_KEYS = (
    "toplevel",
    "sources",
    "test_module",
    "parameters",
    "build_args",
    "test_args",
)


@dataclass
class TestConfig:
    """One entry of tests.json: what to build and which tests to run."""

    __test__ = False

    toplevel: str
    sources: list[str]
    test_module: str
    parameters: dict[str, bool | int | str] | None = None
    build_args: list[str] = field(default_factory=list[str])
    test_args: list[str] = field(default_factory=list[str])


def build_directory(config: TestConfig) -> Path:
    """Return the build directory of a test, by its group."""
    module = config.test_module
    if ".instructions." in module:
        leaf = module.split(".")[-1]
        return TESTS_ROOT / "python/sim_build/instructions" / leaf
    group = "entities" if ".entities." in module else "misc"
    return TESTS_ROOT / "python/sim_build" / group / config.toplevel


def resolve_parameter(value: bool | int | str) -> str:
    """Turn a tests.json generic into a simulator string."""
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    # A path relative to the current directory, or else to the repo.
    for candidate in (Path(value), REPO_ROOT / value):
        if candidate.exists():
            return str(candidate.resolve())
    return str(value)


def run_cocotb_test(config: TestConfig) -> None:
    """Build and simulate one entity; raise if a cocotb test fails."""
    sys.path.append(str(REPO_ROOT))
    runner = get_runner(os.getenv("SIM", "ghdl"))
    build_dir = build_directory(config)
    build_dir.mkdir(parents=True, exist_ok=True)
    parameters = {
        key: resolve_parameter(value)
        for key, value in (config.parameters or {}).items()
    }

    runner.build(
        vhdl_sources=[REPO_ROOT / src for src in config.sources],
        hdl_toplevel=config.toplevel,
        always=True,
        build_dir=build_dir,
        parameters=parameters,
        build_args=config.build_args,
    )

    wave_file = build_dir / "waves.ghw"
    results_xml = runner.test(
        hdl_toplevel=config.toplevel,
        hdl_toplevel_lang="vhdl",
        test_module=config.test_module,
        build_dir=build_dir,
        plusargs=[f"--wave={wave_file}"],
        test_args=config.test_args,
    )
    print(f"Waves: {wave_file} (gerado)")

    # runner.test() returns normally when a cocotb test fails; the
    # failures are only in results.xml.
    total, failed = get_results(results_xml)
    if failed:
        raise RuntimeError(f"{failed} of {total} cocotb tests failed")


def load_configs() -> dict[str, dict[str, Any]]:
    """Read tests.json, exiting with a message if it is unusable."""
    json_path = TESTS_ROOT / "python/tests.json"
    try:
        with json_path.open() as handle:
            configs: dict[str, dict[str, Any]] = json.load(handle)
            return configs
    except FileNotFoundError:
        sys.exit(f"Erro: Arquivo '{json_path}' não encontrado.")
    except json.JSONDecodeError:
        sys.exit(f"Erro: O arquivo JSON '{json_path}' está mal formatado.")


def to_config(entry: dict[str, Any]) -> TestConfig:
    """Build a TestConfig from a tests.json entry, minus skip keys."""
    return TestConfig(**{k: v for k, v in entry.items() if k in CONFIG_KEYS})


def run_all(configs: dict[str, dict[str, Any]]) -> None:
    """Run every non-skipped test and exit 1 if any of them failed."""
    print("Executando TODOS os testes definidos em tests.json...")
    failures: list[str] = []
    for name, entry in configs.items():
        banner = "=" * 20
        if entry.get("skip"):
            reason = entry.get("skip_reason", "no reason given")
            print(f"\n{banner} PULANDO TESTE: {name.upper()} {banner}")
            print(f"[SKIP] {reason}")
            continue
        print(f"\n{banner} INICIANDO TESTE: {name.upper()} {banner}")
        try:
            run_cocotb_test(to_config(entry))
        except (RuntimeError, OSError, subprocess.SubprocessError) as error:
            failures.append(name)
            print(f"[ERRO] O teste '{name}' falhou: {error}")
        else:
            print(f"{'-' * 20} TESTE {name.upper()} FINALIZADO COM SUCESSO")
    print("\nTodos os testes foram executados.")
    if failures:
        sys.exit(f"[ERRO] {len(failures)} falharam: {', '.join(failures)}")


def run_one(name: str, entry: dict[str, Any]) -> None:
    """Run one test by name, even if tests.json marks it as skipped."""
    print(f"Executando teste específico: {name}")
    if entry.get("skip"):
        reason = entry.get("skip_reason", "no reason given")
        print(f"[AVISO] '{name}' está marcado como skip ({reason});")
        print("rodando mesmo assim, por ter sido pedido explicitamente.")
    run_cocotb_test(to_config(entry))
    print(f"\nTeste {name} finalizado.")


def main() -> None:
    """Parse the command line and run one test or all of them."""
    configs = load_configs()
    options = [*configs, "all"]
    parser = argparse.ArgumentParser(
        description="Runner de Testes Cocotb do Common-Components"
    )
    parser.add_argument(
        "test_name",
        nargs="?",
        default="all",
        help=f"Nome do teste a ser executado. Opções: {options}",
    )
    name = parser.parse_args().test_name
    if name == "all":
        run_all(configs)
    elif name in configs:
        run_one(name, configs[name])
    else:
        sys.exit(f"Erro: Teste '{name}' não encontrado. Opções: {options}")


if __name__ == "__main__":
    main()
