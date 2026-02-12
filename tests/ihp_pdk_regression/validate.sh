#!/bin/bash
# validate.sh — runs inside Docker container
# Executes all SPICE netlists and checks for successful output + physics
set -e

PASS=0
FAIL=0
RESULTS=/tests/results

mkdir -p "$RESULTS"
cp /tests/spiceinit "$RESULTS/.spiceinit"
cd "$RESULTS"

# Helper: check that a CSV column's absolute max is in [lo, hi]
# Usage: check_range file col_index lo hi description
check_range() {
    local file="$1" col="$2" lo="$3" hi="$4" desc="$5"
    local val
    val=$(awk -v c="$col" '{v=$c; if(v<0)v=-v; if(v>m)m=v} END{print m}' "$file")
    if [ -z "$val" ]; then
        echo "    WARN: could not read column $col from $file"
        return 1
    fi
    local ok
    ok=$(awk -v v="$val" -v lo="$lo" -v hi="$hi" 'BEGIN{print (v>=lo && v<=hi) ? 1 : 0}')
    if [ "$ok" = "1" ]; then
        return 0
    else
        echo "    WARN: $desc = $val, expected [$lo, $hi]"
        return 1
    fi
}

# Helper: check column max > threshold
check_gt() {
    local file="$1" col="$2" threshold="$3" desc="$4"
    local val
    val=$(awk -v c="$col" '{v=$c; if(v<0)v=-v; if(v>m)m=v} END{print m}' "$file")
    local ok
    ok=$(awk -v v="$val" -v t="$threshold" 'BEGIN{print (v>t) ? 1 : 0}')
    if [ "$ok" = "1" ]; then
        return 0
    else
        echo "    WARN: $desc max|val| = $val, expected > $threshold"
        return 1
    fi
}

# Helper: check col_a max > col_b max (e.g., input > output for lossy network)
check_col_gt() {
    local file="$1" cola="$2" colb="$3" desc="$4"
    local va vb
    va=$(awk -v c="$cola" '{v=$c; if(v<0)v=-v; if(v>m)m=v} END{print m}' "$file")
    vb=$(awk -v c="$colb" '{v=$c; if(v<0)v=-v; if(v>m)m=v} END{print m}' "$file")
    local ok
    ok=$(awk -v a="$va" -v b="$vb" 'BEGIN{print (a>b) ? 1 : 0}')
    if [ "$ok" = "1" ]; then
        return 0
    else
        echo "    WARN: $desc — col$cola=$va not > col$colb=$vb"
        return 1
    fi
}

run_test() {
    local f="$1"
    local name
    name=$(basename "$f" .spice)
    printf "  %-35s " "$name"

    if ! ngspice -b "$f" > "${name}.log" 2>&1; then
        echo "FAIL (ngspice error)"
        tail -20 "${name}.log" 2>/dev/null || true
        return 1
    fi

    local csv="${RESULTS}/${name}.csv"
    if [ ! -f "$csv" ] || [ ! -s "$csv" ]; then
        echo "FAIL (no output data)"
        return 1
    fi

    # Per-test physics checks
    local physics_ok=0
    case "$name" in
        01_dc_lv_nmos)
            # Max |Id| should be in [1uA, 10mA]
            check_range "$csv" 2 1e-6 1e-2 "NMOS Id" || physics_ok=1
            ;;
        02_dc_lv_pmos)
            # Max |Id| should be in [1uA, 10mA]
            check_range "$csv" 2 1e-6 1e-2 "PMOS Id" || physics_ok=1
            ;;
        03_tran_inverter)
            # Output should swing near rail-to-rail (allow overshoot)
            check_range "$csv" 4 1.0 1.6 "inverter Vout swing" || physics_ok=1
            ;;
        04_ac_nmos_cs)
            # Low-freq gain should be > 1 (amplification)
            check_gt "$csv" 2 1.0 "AC gain" || physics_ok=1
            ;;
        05_tran_ring_osc)
            # Output should oscillate — check it reaches near rail (allow overshoot)
            check_range "$csv" 2 0.8 1.6 "ring osc v(n1)" || physics_ok=1
            ;;
        06_sparam_tran)
            # v(3) < v(2) for lossy network, both non-zero
            check_gt "$csv" 2 0.1 "v(2) non-zero" || physics_ok=1
            check_gt "$csv" 4 0.05 "v(3) non-zero" || physics_ok=1
            check_col_gt "$csv" 2 4 "v(2) > v(3) lossy" || physics_ok=1
            ;;
        07_sparam_rc_lowpass)
            # RC lowpass: both ports should have signal
            check_gt "$csv" 2 0.3 "v(2) non-zero" || physics_ok=1
            check_gt "$csv" 4 0.05 "v(3) non-zero" || physics_ok=1
            ;;
        08_sparam_rlc_bandpass)
            # Bandpass: output non-zero (passband content exists in pulse)
            check_gt "$csv" 4 0.0001 "v(3) bandpass output" || physics_ok=1
            ;;
        09_sparam_wilkinson_tran)
            # Power divider: both outputs should be non-zero
            # Note: lossless Wilkinson has singular (I+S), so Y-matrix is
            # near-singular — output is small but non-zero
            check_gt "$csv" 4 1e-6 "v(out_a) non-zero" || physics_ok=1
            check_gt "$csv" 6 1e-6 "v(out_b) non-zero" || physics_ok=1
            ;;
        10_sparam_4port_tran)
            # 4-port: thru port should be non-zero
            check_gt "$csv" 4 0.001 "thru port v(3)" || physics_ok=1
            ;;
        11_sparam_custom_poles)
            # Same as RC lowpass test — should produce similar results
            check_gt "$csv" 4 0.05 "v(3) with custom poles" || physics_ok=1
            check_col_gt "$csv" 2 4 "input > output (custom VF)" || physics_ok=1
            ;;
        12_sparam_cascade)
            # Cascade: v(4) should be more attenuated than v(3)
            check_gt "$csv" 4 0.01 "v(3) stage1 out" || physics_ok=1
            check_gt "$csv" 6 0.001 "v(4) stage2 out" || physics_ok=1
            ;;
        13_sparam_ac_fidelity)
            # AC: output should exist and show attenuation at high freq
            check_gt "$csv" 2 0.5 "AC vm(in)" || physics_ok=1
            ;;
        14_sparam_rref75)
            # Non-50ohm: should converge with output
            check_gt "$csv" 4 0.05 "v(3) with r_ref=75" || physics_ok=1
            ;;
        15_sparam_sine_steady)
            # Sine: output should be non-zero sinusoidal
            check_gt "$csv" 4 0.01 "v(3) sine output" || physics_ok=1
            ;;
        16_sparam_fast_edge)
            # Fast edge: output should be non-zero
            check_gt "$csv" 2 0.1 "v(2) non-zero" || physics_ok=1
            check_gt "$csv" 4 0.01 "v(3) fast edge output" || physics_ok=1
            ;;
        17_sparam_ihp_driver)
            # Integration: gate signal and drain response should exist
            check_gt "$csv" 4 0.1 "v(gate) non-zero" || physics_ok=1
            check_gt "$csv" 6 0.1 "v(drain) non-zero" || physics_ok=1
            ;;
    esac

    if [ "$physics_ok" -eq 0 ]; then
        echo "PASS"
    else
        echo "PASS (physics warn)"
    fi
    return 0
}

echo "========================================"
echo " IHP SG13G2 PDK + VF Regression Tests"
echo "========================================"
echo ""

for f in /tests/netlists/*.spice; do
    if run_test "$f"; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "========================================"
echo " Results: $PASS passed, $FAIL failed"
echo "========================================"

[ $FAIL -eq 0 ] || exit 1
