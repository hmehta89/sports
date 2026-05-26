#!/usr/bin/env bash
# Tests for Matches API — requires a running server at localhost:8080
set -euo pipefail

BASE="http://localhost:8080/api"

echo "========================================"
echo "  MATCHES API TESTS"
echo "========================================"

# Setup: create two teams
echo ""
echo "--- Setup: creating home team (Lakers) ---"
HOME_RESPONSE=$(curl -s -X POST "${BASE}/teams/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}')
echo "$HOME_RESPONSE"
HOME_ID=$(echo "$HOME_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)

echo ""
echo "--- Setup: creating away team (Celtics) ---"
AWAY_RESPONSE=$(curl -s -X POST "${BASE}/teams/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Celtics","city":"Boston","sport":"Basketball","founded_year":1946}')
echo "$AWAY_RESPONSE"
AWAY_ID=$(echo "$AWAY_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)

echo "Home team ID: ${HOME_ID}, Away team ID: ${AWAY_ID}"

# 1. POST — schedule a match
echo ""
echo "--- POST /api/matches/ (schedule match) ---"
CREATE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "${BASE}/matches/" \
  -H "Content-Type: application/json" \
  -d "{\"home_team\":${HOME_ID},\"away_team\":${AWAY_ID},\"date\":\"2025-06-15T20:00:00Z\",\"status\":\"scheduled\"}")
echo "$CREATE_RESPONSE"
MATCH_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
echo "Captured match ID: ${MATCH_ID}"

# 2. GET — list all matches
echo ""
echo "--- GET /api/matches/ (list all) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "${BASE}/matches/"
echo ""

# 3. GET — single match
echo ""
echo "--- GET /api/matches/${MATCH_ID}/ (retrieve single) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "${BASE}/matches/${MATCH_ID}/"
echo ""

# 4. PUT — update the match
echo ""
echo "--- PUT /api/matches/${MATCH_ID}/ (full update to live) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X PUT "${BASE}/matches/${MATCH_ID}/" \
  -H "Content-Type: application/json" \
  -d "{\"home_team\":${HOME_ID},\"away_team\":${AWAY_ID},\"date\":\"2025-06-15T20:00:00Z\",\"status\":\"live\"}"
echo ""

# 5. POST — update_score action
echo ""
echo "--- POST /api/matches/${MATCH_ID}/update_score/ (update score) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "${BASE}/matches/${MATCH_ID}/update_score/" \
  -H "Content-Type: application/json" \
  -d '{"home_score":112,"away_score":108,"status":"completed"}'
echo ""

# 6. DELETE — remove the match
echo ""
echo "--- DELETE /api/matches/${MATCH_ID}/ (delete) ---"
curl -s -w "\nHTTP_STATUS:%{http_code}" -X DELETE "${BASE}/matches/${MATCH_ID}/"
echo ""

# Cleanup: remove teams
echo ""
echo "--- Cleanup: deleting teams ---"
curl -s -o /dev/null -X DELETE "${BASE}/teams/${HOME_ID}/"
curl -s -o /dev/null -X DELETE "${BASE}/teams/${AWAY_ID}/"
echo "Teams deleted."

echo ""
echo "========================================"
echo "  MATCHES TESTS COMPLETE"
echo "========================================"
