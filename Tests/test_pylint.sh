#!/usr/bin/env bash
# ==========================================================
# Run pylint style checks on the two demo notebooks via nbqa.
# Target: score >= 8.0/10 with zero E (error) messages.
#
# Usage:  bash test_pylint.sh
#
# Requirements:  pip install nbqa pylint
# ==========================================================

set -euo pipefail

echo "============================================"
echo " PYLINT STYLE CHECKS  (target: >= 8.0, 0 E)"
echo "============================================"
echo ""

FAILED=0

for NB in demo_bls.ipynb demo_cnn.ipynb; do
    echo "--- $NB ---"
    OUTPUT=$(nbqa pylint "$NB" 2>&1) || true
    echo "$OUTPUT"
    echo ""

    # Extract score (e.g. "rated at 9.49/10")
    SCORE=$(echo "$OUTPUT" | grep -oP 'rated at \K[0-9.]+')
    E_COUNT=$(echo "$OUTPUT" | grep -cP '^[^:]+:[^:]+:[0-9]+:[0-9]+: E' || true)

    if [ -n "$SCORE" ]; then
        if (( $(echo "$SCORE >= 8.0" | bc -l) )) && [ "$E_COUNT" -eq 0 ]; then
            echo "  PASSED  (score: $SCORE, E errors: 0)"
        else
            echo "  FAILED  (score: $SCORE, E errors: $E_COUNT)"
            FAILED=1
        fi
    else
        echo "  FAILED  (could not parse score)"
        FAILED=1
    fi
    echo ""
done

echo "============================================"
if [ "$FAILED" -eq 0 ]; then
    echo " ALL PYLINT CHECKS PASSED"
else
    echo " SOME CHECKS FAILED — see output above"
fi
echo "============================================"
