#!/usr/bin/env bash
# Formal verification of the synchronizer and the three registers with SymbiYosys. Needs
# ghdl, yosys, sby and the engine chosen by FORMAL_ENGINE (all in the ci-vhdl image). Run from the root of the
# repository:  FORMAL_ENGINE=bitwuzla bash formal/run.sh
#
# FORMAL_ENGINE is one of yices, bitwuzla (the default), boolector and abc-bmc3. The first three are SMT solvers
# of the smtbmc engine; abc-bmc3 is the bounded model checker of ABC, which has no induction and no cover, so it
# skips those proofs. FORMAL_TIMEOUT (seconds, 900 by default) bounds each proof.
#
# Besides the report, the run writes build/formal/result-<engine>.tsv, one line per proof with the columns
# id, wanted (pass or fail), verdict (pass, fail, error or skip), sby exit code, milliseconds and the label, which
# formal/aggregate.sh joins across engines.
#
# A warning is an error. Every ghdl and sby/yosys output of the run (the proofs and the mutants) goes through
# scan_warnings; any line with the word "warning" makes the run fail, naming the file and the line. The flags
# that hide warnings (-Wno-*) are not used: the cause of a warning is fixed in the VHDL or in the proofs.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$root/build/formal"
rm -rf "$out"; mkdir -p "$out"; cd "$out"

engine="${FORMAL_ENGINE:-bitwuzla}"
case "$engine" in
  yices|bitwuzla|boolector|abc-bmc3) ;;
  *) echo "FORMAL_ENGINE must be yices, bitwuzla, boolector or abc-bmc3, not '$engine'" >&2; exit 2 ;;
esac
timeout_s="${FORMAL_TIMEOUT:-900}"
results="$out/result-$engine.tsv"; : > "$results"

fail=0
warnings="$out/warnings.txt"; : > "$warnings"

# scan_warnings <log>: records in warnings.txt, and prints on stderr, every line of <log> that has the word
# "warning" (case-insensitive, as a whole word or its plural: ghdl ":warning:", yosys "Warning:", sby "warning").
# A name such as warning_count does not match, because the underscore is part of the word, and the summary
# "Warnings: 0 unique messages, 0 total" of yosys is skipped. The files are scanned after the tool ends, in the
# main shell or in the subshell of prove, so the failure is decided at the end of the run, from warnings.txt.
# One exception, exact and only for the abc-bmc3 engine: ABC itself prints "Warning:" about the AIGER file that
# SymbiYosys hands it (the clock input is consumed by the clk2ff step, and ABC announces how many outputs it reads
# as constraints, or that there is none). They describe the tool's own file format, not the design or the
# proofs, and cannot be removed from the design; see abc_notes below. Everything else still fails the run.
# To reuse in another repository: copy this function, the warnings.txt lines and the final check.
abc_notes='(aig: Warning: Treating undriven bit props\.\\clk like \$anyseq\.|aig: Warning: Treating a total of 1 undriven bits in props like \$anyseq\.|engine_0: Warning: (The last (output is|[0-9]+ outputs are) interpreted as (a )?constraints?\.|The network has no constraints\.))$'
scan_warnings() {
  local line ignore='^$^'
  [ "$engine" = abc-bmc3 ] && [[ "$1" == *.log && "$1" != *.ghdl.log ]] && ignore="$abc_notes"
  { grep -inE '(^|[^[:alnum:]_])warnings?([^[:alnum:]_]|$)' "$1" || true; } \
    | { grep -viE 'warnings?: 0 (unique )?(messages|total)' || true; } \
    | { grep -vE "$ignore" || true; } \
    | while IFS= read -r line; do
        printf 'formal: WARNING treated as error: %s:%s\n' "${1#"$root"/}" "$line" | tee -a "$warnings" >&2
      done
}

# expect <label> <wanted: PASS|FAIL> <result: PASS|FAIL|SKIP|ERROR ...>. An ERROR (the tool did not reach a verdict)
# never matches, not even a wanted FAIL; a SKIP is a proof this engine does not do and is not a failure. The id,
# the exit code and the time of the proof come from the files prove left for its tag.
expect() {
  local tag verdict rc ms
  tag="$(cat "$out/.last")"
  IFS=$'\t' read -r verdict rc ms < "$out/$tag.res"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$tag" "${2,,}" "$verdict" "$rc" "$ms" "$1" >> "$results"
  case "$3" in
    SKIP*) printf '  skip  %-62s %s\n' "$1" "${3#SKIP }" ;;
    ERROR*) printf '  ERROR %-62s %s\n' "$1" "${3#ERROR }"; fail=1 ;;
    "$2") printf '  ok    %-62s %s (%s ms)\n' "$1" "$3" "$ms" ;;
    *) printf '  WRONG %-62s wanted %s, got %s\n' "$1" "$2" "$3"; fail=1 ;;
  esac
}

# netlist <vhdl> <entity> <name> [ghdl generics]: the Verilog netlist GHDL synthesizes for the entity. The
# mutant takes the place of the original unit in the analysis order: REPLACES names the file the mutant stands
# for, and the file under proof ($1) is analyzed in its place. The Quartus attribute of the synchronizer (altera_attribute) is
# unknown to GHDL, which warns about it; it only annotates the signal for Quartus and has no logic, so the copy
# analyzed here is without it.
netlist() {
  local work="$out/work_$3" replaces="${REPLACES:-$1}" log="$out/$3.ghdl.log" file name
  mkdir -p "$work"; : > "$log"
  for file in "$root/src/flip_flop.vhd" "$root/src/generic_register.vhd" "$root/src/synchronizer.vhd" \
              "$root/src/clearable_register.vhd"; do
    [ "$file" = "$replaces" ] && file="$1"
    name="$work/$(basename "$file")"
    sed '/attribute altera_attribute/,/";$/d' "$file" > "$name"
    ghdl -a --std=08 --workdir="$work" "$name" 2>> "$log" || { cat "$log" >&2; return 1; }
  done
  ghdl --synth --std=08 --workdir="$work" --out=verilog ${@:4} "$2" > "$3.v" 2>> "$log" || { cat "$log" >&2; return 1; }
  scan_warnings "$log"
}

# prove <netlist> <props> <mode: prove|bmc|cover> <depth> <defines> <tag>  ->  PASS, FAIL, SKIP or ERROR
# PASS is sby exit code 0, FAIL is 2 (a counterexample or a goal that cannot be covered) and any other code
# (4 unknown, 8 timeout, 16 error, 124 the FORMAL_TIMEOUT) is ERROR: the tool did not reach a verdict. The
# abc-bmc3 engine only checks bounded properties of designs with registers, so it answers SKIP for a proof by
# induction, for a cover and for a combinational design.
# The verdict, the exit code and the milliseconds go to <tag>.res, and the tag to .last, for expect.
prove() {
  echo "$6" > "$out/.last"
  local engine_lines script_lines options_lines="" rc=0 verdict began ended
  case "$engine" in
    abc-bmc3)
      if [ "$3" != bmc ]; then
        printf 'SKIP\t-\t0\n' > "$6.res"; echo "SKIP abc-bmc3 has no $3"; return
      fi
      engine_lines="abc bmc3"
      options_lines="aigsmt none"
      script_lines=$'techmap\nopt -fast\nsetundef -anyseq' ;;
    *) engine_lines="smtbmc $engine"; script_lines="" ;;
  esac
  cat > "$6.sby" <<EOS
[options]
mode $3
depth $4
$options_lines
[engines]
$engine_lines
[script]
read_verilog -formal -sv $5 $1 $2
prep -top props
$script_lines
[files]
$1
$2
EOS
  began=$(date +%s%N)
  timeout "$timeout_s" sby -f "$6.sby" > "$6.log" 2>&1 || rc=$?
  ended=$(date +%s%N)
  scan_warnings "$6.log"
  # ABC refuses a design without registers (the trap unit is combinational): that is a proof this engine does
  # not do, not a failure of the tool.
  if [ "$engine" = abc-bmc3 ] && [ "$rc" = 16 ] && grep -q 'Does not work for combinational networks' "$6.log"; then
    printf 'skip\t%s\t0\n' "$rc" > "$6.res"; echo "SKIP abc-bmc3 does not work for a combinational design"; return
  fi
  case "$rc" in
    0) verdict=PASS ;;
    2) verdict=FAIL ;;
    *) verdict=ERROR ;;
  esac
  printf '%s\t%s\t%s\n' "${verdict,,}" "$rc" "$(( (ended - began) / 1000000 ))" > "$6.res"
  case "$verdict" in
    ERROR) echo "ERROR sby exited with code $rc, not a verdict (see $6.log)" ;;
    *) echo "$verdict" ;;
  esac
}

src="$root/src"; f="$root/formal"

echo "synchronizer"
netlist "$src/synchronizer.vhd" synchronizer sync2 -gstages=2 -gdata_width=2
expect "latency of two edges, zero after a reset, any input sequence (induction, 2 stages)" PASS "$(prove sync2.v "$f/synchronizer_props.sv" prove 6 '-DSTAGES=2 -DWIDTH=2' sync2_safety)"
expect "cover: a sample reaches the output and a reset empties the chain (2 stages)" PASS "$(prove sync2.v "$f/synchronizer_props.sv" cover 12 '-DSTAGES=2 -DWIDTH=2 -DCOVER' sync2_cover)"
netlist "$src/synchronizer.vhd" synchronizer sync3 -gstages=3 -gdata_width=1
expect "latency of three edges, zero after a reset, any input sequence (induction, 3 stages)" PASS "$(prove sync3.v "$f/synchronizer_props.sv" prove 8 '-DSTAGES=3 -DWIDTH=1' sync3_safety)"

echo "flip_flop"
netlist "$src/flip_flop.vhd" flip_flop ff
expect "reset has priority, enable loads, no enable holds (induction)" PASS "$(prove ff.v "$f/flip_flop_props.sv" prove 4 '' ff_safety)"
expect "cover: a load and a hold of a one are reachable" PASS "$(prove ff.v "$f/flip_flop_props.sv" cover 10 '-DCOVER' ff_cover)"

echo "generic_register"
netlist "$src/generic_register.vhd" generic_register reg4 -gdata_width=4
expect "reset has priority, enable loads, no enable holds (induction)" PASS "$(prove reg4.v "$f/generic_register_props.sv" prove 4 '-DWIDTH=4' reg_safety)"
expect "cover: a load and a hold of a non-zero value are reachable" PASS "$(prove reg4.v "$f/generic_register_props.sv" cover 10 '-DWIDTH=4 -DCOVER' reg_cover)"

echo "clearable_register"
netlist "$src/clearable_register.vhd" clearable_register clr0 -gdata_width=4 -gclear_value="'0'"
expect "clear beats enable, enable loads, otherwise holds; clear to zeros (induction)" PASS "$(prove clr0.v "$f/clearable_register_props.sv" prove 4 "-DWIDTH=4 -DCLEAR=1'b0" clr0_safety)"
netlist "$src/clearable_register.vhd" clearable_register clr1 -gdata_width=4 -gclear_value="'1'"
expect "clear beats enable, enable loads, otherwise holds; clear to ones (induction)" PASS "$(prove clr1.v "$f/clearable_register_props.sv" prove 4 "-DWIDTH=4 -DCLEAR=1'b1" clr1_safety)"
expect "cover: a clear together with an enable and a plain load are reachable" PASS "$(prove clr0.v "$f/clearable_register_props.sv" cover 10 "-DWIDTH=4 -DCLEAR=1'b0 -DCOVER" clr0_cover)"

# Units without a proof that other repositories synthesize: GHDL must synthesize them without a warning.
# synth_only <entity> <name> <vhdl files in order> -- [ghdl generics]
synth_only() {
  local entity="$1" name="$2" work log files=() file
  work="$out/work_$2"; log="$out/$2.ghdl.log"; mkdir -p "$work"; : > "$log"
  shift 2
  while [ "$1" != -- ]; do files+=("$1"); shift; done; shift
  for file in "${files[@]}"; do
    ghdl -a --std=08 --workdir="$work" "$file" 2>> "$log" || { cat "$log" >&2; return 1; }
  done
  ghdl --synth --std=08 --workdir="$work" --out=verilog "$@" "$entity" > "$name.v" 2>> "$log" || { cat "$log" >&2; return 1; }
  scan_warnings "$log"
  printf '  ok    %-62s synthesized\n' "$entity $*"
}
echo "mux_tree (synthesis only)"
synth_only mux_tree mux_tree_a "$src/utils_pkg.vhd" "$src/mux_tree.vhd" -- -gselector_width=2 -gdata_width=4
synth_only mux_tree mux_tree_b "$src/utils_pkg.vhd" "$src/mux_tree.vhd" -- -gselector_width=3 -gdata_width=1

# Mutants of the VHDL: each defect must make a proof fail.
mutant() {  # <file> <props> <entity> <defines> <name> <sed expression> [ghdl generics] [bmc depth]
  local copy="$out/mut_$5.vhd"
  sed "$6" "$1" > "$copy"
  cmp -s "$1" "$copy" && { echo "mutant $5: the edit did not change the file"; exit 1; }
  REPLACES="$1" netlist "$copy" "$3" "mut_$5" ${7:-}
  expect "mutant $5 is caught" FAIL "$(prove "mut_$5.v" "$2" bmc "${8:-8}" "$4" "mut_$5")"
}
sy="$src/synchronizer.vhd"; sp="$f/synchronizer_props.sv"
mutant "$sy" "$sp" synchronizer '-DSTAGES=2 -DWIDTH=2' sync_short_chain  "s/o_d <= chain(stages - 1);/o_d <= chain(stages - 2);/" "-gstages=2 -gdata_width=2" 8
mutant "$sy" "$sp" synchronizer '-DSTAGES=2 -DWIDTH=2' sync_long_chain   "s/o_d <= chain(stages - 1);/o_d <= chain(0);/" "-gstages=2 -gdata_width=2" 8
mutant "$sy" "$sp" synchronizer '-DSTAGES=2 -DWIDTH=2' sync_reset_ignored "s/if i_rst = '1' then/if false then/" "-gstages=2 -gdata_width=2" 8
mutant "$sy" "$sp" synchronizer '-DSTAGES=2 -DWIDTH=2' sync_reset_stage0_only "s/chain <= (others => (others => '0'));/chain(0) <= (others => '0');/" "-gstages=2 -gdata_width=2" 8
ffv="$src/flip_flop.vhd"; ffp="$f/flip_flop_props.sv"
mutant "$ffv" "$ffp" flip_flop '' ff_enable_ignored "s/if (i_enable = '1') then/if true then/" "" 6
mutant "$ffv" "$ffp" flip_flop '' ff_no_async_reset "s/if (i_rst = '1') then/if (i_rst = '1' and rising_edge(i_clk)) then/" "" 6
mutant "$ffv" "$ffp" flip_flop '' ff_reset_to_one "s/o_d <= '0';/o_d <= '1';/" "" 6
grv="$src/generic_register.vhd"; grp="$f/generic_register_props.sv"
mutant "$grv" "$grp" generic_register '-DWIDTH=4' reg_enable_ignored "s/if (i_enable = '1') then/if true then/" "-gdata_width=4" 6
mutant "$grv" "$grp" generic_register '-DWIDTH=4' reg_reset_one_bit "s/o_d <= (others => '0');/o_d <= (0 => '1', others => '0');/" "-gdata_width=4" 6
mutant "$grv" "$grp" generic_register '-DWIDTH=4' reg_no_hold "s/o_d <= i_d;/o_d <= not i_d;/" "-gdata_width=4" 6
crv="$src/clearable_register.vhd"; crp="$f/clearable_register_props.sv"
mutant "$crv" "$crp" clearable_register "-DWIDTH=4 -DCLEAR=1'b0" clr_enable_wins "s/load_data   <= (others => clear_value) when i_clear = '1' else i_d;/load_data   <= i_d when i_enable = '1' else (others => clear_value);/" "-gdata_width=4 -gclear_value='0'" 6
mutant "$crv" "$crp" clearable_register "-DWIDTH=4 -DCLEAR=1'b0" clr_no_clear "s/load_enable <= i_clear or i_enable;/load_enable <= i_enable;/" "-gdata_width=4 -gclear_value='0'" 6
mutant "$crv" "$crp" clearable_register "-DWIDTH=4 -DCLEAR=1'b1" clr_wrong_value "s/(others => clear_value) when/(others => '0') when/" "-gdata_width=4 -gclear_value='1'" 6

[ -s "$warnings" ] && { echo "formal: $(wc -l < "$warnings") warning(s) found; a warning is an error (see above)"; fail=1; }
[ "$fail" -eq 0 ] && echo "formal: all expectations met" || { echo "formal: FAILED (logs in build/formal)"; exit 1; }
