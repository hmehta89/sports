#!/usr/bin/env bash
# Runs all API test scripts and prints a summary.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="http://localhost:8080/api"
PASS=0
FAIL=0

run_suite() {
    local name="$1"
    local script="$2"
    echo ""
    echo "###################################"
    echo "#  Running: ${name}"
    echo "###################################"
    if bash "${script}"; then
        echo "[OK] ${name} passed"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] ${name} failed (exit $?)"
        FAIL=$((FAIL + 1))
    fi
}

# Check server is reachable before running tests
echo "Checking server at ${BASE}/teams/ ..."
if ! curl -sf "${BASE}/teams/" > /dev/null 2>&1; then
    echo "ERROR: Server not reachable at ${BASE}."
    echo "Start it with: cd src && python manage.py runserver 8080"
    exit 1
fi
echo "Server is up."

run_suite "Teams"   "${SCRIPT_DIR}/test_teams.sh"
run_suite "Players" "${SCRIPT_DIR}/test_players.sh"
run_suite "Matches" "${SCRIPT_DIR}/test_matches.sh"

echo ""
echo "========================================"
echo "  SUMMARY"
echo "  Passed: ${PASS}/3"
echo "  Failed: ${FAIL}/3"
echo "========================================"

[ "${FAIL}" -eq 0 ]
