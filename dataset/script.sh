#!/usr/bin/env bash
# ==========================================================
# PSLS DATASET GENERATOR (stable v2)
# 1000 runs total
# 50% transit / 50% no transit
# Parallel jobs configurable
# Original psls.yaml is never modified
# ==========================================================

set -euo pipefail

# ----------------------------------------------------------
# USER SETTINGS
# ----------------------------------------------------------
BASE_YAML="psls.yaml"
TOTAL_RUNS=1000
PARALLEL_JOBS=4          # lower if PC struggles
OUTDIR="dataset"
METADATA="${OUTDIR}/metadata.csv"

# Fixed output produced by PSLS for current stellar model
RAW_OUTPUT="0012069449.dat"

mkdir -p "$OUTDIR"

if [ ! -f "$METADATA" ]; then
    echo "file,label,period_days,radius_rj,noise_ppmhr,sigma_ppm,seed,a_au" > "$METADATA"
fi

# ==========================================================
# FUNCTION
# ==========================================================
run_one_sim () {

RUNID="$1"

WORKDIR=$(mktemp -d)
YAML="${WORKDIR}/run.yaml"

cp "$BASE_YAML" "$YAML"

# ----------------------------------------------------------
# RANDOM PARAMETERS
# ----------------------------------------------------------

# independent random numbers using awk seeded by time+runid
N=$(awk -v r="$RUNID" 'BEGIN{srand(systime()+r); printf "%.3f",10+rand()*70}')
S=$(awk -v r="$RUNID" 'BEGIN{srand(systime()+1000+r); printf "%.3f",5+rand()*55}')
SEED=$(( RANDOM * RANDOM + RUNID + $$ ))

HALF=$(( TOTAL_RUNS / 2 ))

# ----------------------------------------------------------
# LABELS
# 1 = transit
# 0 = no transit
# ----------------------------------------------------------

if [ "$RUNID" -le "$HALF" ]; then
    LABEL=1
else
    LABEL=0
fi

if [ "$LABEL" -eq 1 ]; then

    ENABLE=1

    P=$(awk -v r="$RUNID" 'BEGIN{srand(systime()+2000+r); printf "%.3f",1+rand()*364}')
    R=$(awk -v r="$RUNID" 'BEGIN{srand(systime()+3000+r); printf "%.3f",0.05+rand()*0.95}')

    # semi-major axis for Sun-like star
    A=$(awk -v p="$P" 'BEGIN{printf "%.5f",(p/365.25)^(2.0/3.0)}')

else

    ENABLE=0
    P=0
    R=0
    A=0

fi

# ----------------------------------------------------------
# OUTPUT NAME
# ----------------------------------------------------------

NAME=$(printf "run_%04d_label%d_P%s_R%s_N%.0f_S%.0f_seed%d.dat" \
"$RUNID" "$LABEL" "$P" "$R" "$N" "$S" "$SEED")

# ----------------------------------------------------------
# YAML EDITS
# ----------------------------------------------------------

# global scalar replacements
sed -i \
-e "s/^[[:space:]]*MasterSeed[[:space:]]*:.*/  MasterSeed : ${SEED}/" \
-e "s/^[[:space:]]*NSR[[:space:]]*:.*/    NSR : ${N}/" \
-e "s/^[[:space:]]*Sigma[[:space:]]*:.*/  Sigma : ${S}/" \
-e "s/^[[:space:]]*PlanetRadius[[:space:]]*:.*/  PlanetRadius : ${R}/" \
-e "s/^[[:space:]]*OrbitalPeriod[[:space:]]*:.*/  OrbitalPeriod : ${P}/" \
-e "s/^[[:space:]]*PlanetSemiMajorAxis[[:space:]]*:.*/  PlanetSemiMajorAxis : ${A}/" \
"$YAML"

# Transit Enable only inside Transit block
awk -v val="$ENABLE" '
BEGIN{inblock=0}
{
    if ($0 ~ /^Transit[[:space:]]*:/) {inblock=1; print; next}
    if (inblock && $0 ~ /^[^[:space:]]/) {inblock=0}
    if (inblock && $0 ~ /^[[:space:]]*Enable[[:space:]]*:/) {
        print "  Enable: " val
        next
    }
    print
}
' "$YAML" > "${YAML}.tmp" && mv "${YAML}.tmp" "$YAML"

# ----------------------------------------------------------
# RUN PSLS
# ----------------------------------------------------------

(
cd "$WORKDIR"
psls.py run.yaml > /dev/null 2>&1
)

# ----------------------------------------------------------
# HANDLE OUTPUT
# ----------------------------------------------------------

if [ -f "${WORKDIR}/${RAW_OUTPUT}" ]; then
    mv "${WORKDIR}/${RAW_OUTPUT}" "${OUTDIR}/${NAME}"
else
    echo "FAILED RUN ${RUNID}"
    rm -rf "$WORKDIR"
    return
fi

# ----------------------------------------------------------
# METADATA
# ----------------------------------------------------------

echo "${NAME},${LABEL},${P},${R},${N},${S},${SEED},${A}" >> "$METADATA"

echo "Finished run ${RUNID}/${TOTAL_RUNS}"

rm -rf "$WORKDIR"
}

export -f run_one_sim
export BASE_YAML TOTAL_RUNS OUTDIR METADATA RAW_OUTPUT

# ==========================================================
# PARALLEL EXECUTION
# ==========================================================

seq 1 "$TOTAL_RUNS" | xargs -P "$PARALLEL_JOBS" -I{} bash -c 'run_one_sim "$1"' _ {}

echo "======================================"
echo "ALL RUNS COMPLETE"
echo "Files saved in: ${OUTDIR}"
echo "Metadata saved: ${METADATA}"
echo "======================================"
