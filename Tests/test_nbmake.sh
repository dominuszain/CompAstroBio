#!/usr/bin/env bash
# ==========================================================
# Run nbmake execution checks on the two demo notebooks.
# These test that each notebook runs top-to-bottom without
# errors on a fresh kernel.
#
# Usage:  bash test_nbmake.sh
#
# Requirements:  pip install pytest nbmake
# ==========================================================

set -euo pipefail

echo "============================================"
echo " NBMAKE EXECUTION CHECKS"
echo "============================================"
echo ""

FAILED=0

for NB in demo_bls.ipynb demo_cnn.ipynb; do
    echo "--- $NB ---"
    if pytest --nbmake --nbmake-timeout=300 "$NB" -q 2>&1; then
        echo "  PASSED"
    else
        echo "  FAILED"
        FAILED=1
    fi
    echo ""
done

echo "============================================"
if [ "$FAILED" -eq 0 ]; then
    echo " ALL NBMAKE CHECKS PASSED"
else
    echo " SOME CHECKS FAILED — see output above"
fi
echo "============================================"
