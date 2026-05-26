#!/usr/bin/env bash
# Tests for Players API — requires a running server at localhost:8080
# A team must exist. This script creates one first, then cleans up.
set -euo pipefail

BASE="http://localhost:8080/api"

echo "========================================"
echo "  PLAYERS API TESTS"
echo "========================================"

# Setup: create a team to attach players to
echo ""
echo "--- Setup: creating team ---"
TEAM_RESPONSE=$(curl -s -X POST "${BASE}/teams/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}')
echo "$TEAM_RESPONSE"
TEAM_ID=$(echo "$TEAM_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
echo "Team ID: ${TEAM_ID}"

# 1. POST — create a player
echo ""
echo "--- POST /api/players/ (create player) ---"
CREATE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "${BASE}/players/" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"LeBron James\",\"team\":${TEAM_ID},\"position\":\"Small Forward\",\"jersey_number\":23,\"age\":39}")
echo "$CREATE_RESPONSE"
PLAYER_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
echo "Captured player ID: ${PLAYER_ID}"

# 2. GET — list all players
echo ""
echo "--- GET /api/players/ (list all) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "${BASE}/players/"
echo ""

# 3. GET — single player
echo ""
echo "--- GET /api/players/${PLAYER_ID}/ (retrieve single) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "${BASE}/players/${PLAYER_ID}/"
echo ""

# 4. PUT — update the player
echo ""
echo "--- PUT /api/players/${PLAYER_ID}/ (full update) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X PUT "${BASE}/players/${PLAYER_ID}/" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"LeBron James\",\"team\":${TEAM_ID},\"position\":\"Power Forward\",\"jersey_number\":23,\"age\":40}"
echo ""

# 5. DELETE — remove the player
echo ""
echo "--- DELETE /api/players/${PLAYER_ID}/ (delete) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X DELETE "${BASE}/players/${PLAYER_ID}/"
echo ""

# Cleanup: remove the team
echo ""
echo "--- Cleanup: deleting team ---"
curl -s -o /dev/null -X DELETE "${BASE}/teams/${TEAM_ID}/"
echo "Team ${TEAM_ID} deleted."

echo ""
echo "========================================"
echo "  PLAYERS TESTS COMPLETE"
echo "========================================"
