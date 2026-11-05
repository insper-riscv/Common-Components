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
# file under proof comes last, so that a mutant replaces the original unit.
netlist() {
  local work="$out/work_$3"; mkdir -p "$work"
  ghdl -a --std=08 -Wno-library -Wno-unhandled-attribute --workdir="$work" \
    "$root/src/flip_flop.vhd" \
    "$root/src/generic_register.vhd" \
    "$root/src/synchronizer.vhd" \
    "$root/src/clearable_register.vhd" \
    "$1"
  ghdl --synth --std=08 -Wno-library -Wno-unhandled-attribute --workdir="$work" --out=verilog ${@:4} "$2" > "$3.v"
  # The Quartus attribute of the synchronizer has quotes inside its value, which the Verilog reader cannot parse.
  sed -i 's/(\* altera_attribute=.* \*) reg/reg/' "$3.v"
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

# Mutants of the VHDL: each defect must make a proof fail.
mutant() {  # <file> <props> <entity> <defines> <name> <sed expression> [ghdl generics] [bmc depth]
  local copy="$out/mut_$5.vhd"
  sed "$6" "$1" > "$copy"
  cmp -s "$1" "$copy" && { echo "mutant $5: the edit did not change the file"; exit 1; }
  netlist "$copy" "$3" "mut_$5" ${7:-}
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

[ "$fail" -eq 0 ] && echo "formal: all expectations met" || { echo "formal: FAILED (logs in build/formal)"; exit 1; }
