#!/usr/bin/env bash
# Tests for Teams API — requires a running server at localhost:8080
set -euo pipefail

BASE="http://localhost:8080/api"

echo "========================================"
echo "  TEAMS API TESTS"
echo "========================================"

# 1. POST — create a team
echo ""
echo "--- POST /api/teams/ (create team) ---"
CREATE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "${BASE}/teams/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}')
echo "$CREATE_RESPONSE"
TEAM_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
echo "Captured team ID: ${TEAM_ID}"

# 2. GET — list all teams
echo ""
echo "--- GET /api/teams/ (list all) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "${BASE}/teams/"
echo ""

# 3. GET — single team
echo ""
echo "--- GET /api/teams/${TEAM_ID}/ (retrieve single) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "${BASE}/teams/${TEAM_ID}/"
echo ""

# 4. PUT — update the team
echo ""
echo "--- PUT /api/teams/${TEAM_ID}/ (full update) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X PUT "${BASE}/teams/${TEAM_ID}/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}'
echo ""

# 5. DELETE — remove the team
echo ""
echo "--- DELETE /api/teams/${TEAM_ID}/ (delete) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X DELETE "${BASE}/teams/${TEAM_ID}/"
echo ""

echo ""
echo "========================================"
echo "  TEAMS TESTS COMPLETE"
echo "========================================"
