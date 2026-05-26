# Sports API — Kompressa Extraction Demo

Extracted with the **Kompressa feature extraction pipeline** from the `hmehta89/sports` repository.
Three features were identified, extracted into individual folders, and tested with live curl commands.

---

## Repository Structure

```
sports/
├── src/                          # Django REST sports API source
│   ├── manage.py
│   ├── sports_api/               # Root config (settings, urls)
│   ├── teams/                    # Team Management feature
│   ├── players/                  # Player Roster feature
│   └── matches/                  # Match Scheduling feature
├── features/                     # Extracted feature packages
│   ├── team-management/          # models, serializers, views, urls, README
│   ├── player-roster/            # models, serializers, views, urls, README
│   └── match-scheduling/         # models, serializers, views, urls, README
├── tests/                        # Curl-based endpoint test suite
│   ├── test_teams.sh
│   ├── test_players.sh
│   ├── test_matches.sh
│   └── run_all.sh
├── requirements.txt
└── README.md
```

---

## Quick Start

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Set up database
cd src
python manage.py migrate --run-syncdb

# 3. Start server
python manage.py runserver 8080

# 4. Run all tests (in a new terminal)
cd ../tests && bash run_all.sh
```

---

## Extracted Features

| Feature | Endpoints | Source Files |
|---|---|---|
| **Team Management** | `GET/POST /api/teams/` · `GET/PATCH/DELETE /api/teams/{id}/` | `teams/models.py` · `teams/views.py` · `teams/serializers.py` |
| **Player Roster** | `GET/POST /api/players/` · `GET/PATCH/DELETE /api/players/{id}/` | `players/models.py` · `players/views.py` · `players/serializers.py` |
| **Match Scheduling** | `GET/POST /api/matches/` · `GET/PATCH/DELETE /api/matches/{id}/` · `POST /api/matches/{id}/update_score/` | `matches/models.py` · `matches/views.py` · `matches/serializers.py` |

---

## API Test Results (Live Responses)

All responses below are **real responses** captured from a running instance via `bash tests/run_all.sh`.

Base URL: `http://localhost:8080`

---

### Feature 1 — Team Management

#### `POST /api/teams/` — Create a team

```bash
curl -s -X POST http://localhost:8080/api/teams/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Los Angeles Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}'
```

**Response `201 Created`:**
```json
{
    "id": 1,
    "name": "Los Angeles Lakers",
    "city": "Los Angeles",
    "sport": "Basketball",
    "founded_year": 1947
}
```

#### `POST /api/teams/` — Create second team

```bash
curl -s -X POST http://localhost:8080/api/teams/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Boston Celtics","city":"Boston","sport":"Basketball","founded_year":1946}'
```

**Response `201 Created`:**
```json
{
    "id": 2,
    "name": "Boston Celtics",
    "city": "Boston",
    "sport": "Basketball",
    "founded_year": 1946
}
```

#### `GET /api/teams/` — List all teams

```bash
curl -s http://localhost:8080/api/teams/
```

**Response `200 OK`:**
```json
{
    "count": 2,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 2,
            "name": "Boston Celtics",
            "city": "Boston",
            "sport": "Basketball",
            "founded_year": 1946
        },
        {
            "id": 1,
            "name": "Los Angeles Lakers",
            "city": "Los Angeles",
            "sport": "Basketball",
            "founded_year": 1947
        }
    ]
}
```

#### `GET /api/teams/1/` — Get single team

```bash
curl -s http://localhost:8080/api/teams/1/
```

**Response `200 OK`:**
```json
{
    "id": 1,
    "name": "Los Angeles Lakers",
    "city": "Los Angeles",
    "sport": "Basketball",
    "founded_year": 1947
}
```

#### `PATCH /api/teams/1/` — Update a team

```bash
curl -s -X PATCH http://localhost:8080/api/teams/1/ \
  -H "Content-Type: application/json" \
  -d '{"city":"Los Angeles, CA"}'
```

**Response `200 OK`:**
```json
{
    "id": 1,
    "name": "Los Angeles Lakers",
    "city": "Los Angeles, CA",
    "sport": "Basketball",
    "founded_year": 1947
}
```

#### `DELETE /api/teams/1/` — Delete a team

```bash
curl -s -X DELETE http://localhost:8080/api/teams/1/ -w "HTTP %{http_code}\n"
```

**Response `204 No Content`:**
```
HTTP 204
```

---

### Feature 2 — Player Roster

#### `POST /api/players/` — Create players

```bash
curl -s -X POST http://localhost:8080/api/players/ \
  -H "Content-Type: application/json" \
  -d '{"name":"LeBron James","team":1,"position":"Small Forward","jersey_number":23,"age":39}'
```

**Response `201 Created`:**
```json
{
    "id": 1,
    "name": "LeBron James",
    "team": 1,
    "team_name": "Los Angeles Lakers",
    "position": "Small Forward",
    "jersey_number": 23,
    "age": 39
}
```

```bash
curl -s -X POST http://localhost:8080/api/players/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Anthony Davis","team":1,"position":"Center","jersey_number":3,"age":31}'
```

**Response `201 Created`:**
```json
{
    "id": 2,
    "name": "Anthony Davis",
    "team": 1,
    "team_name": "Los Angeles Lakers",
    "position": "Center",
    "jersey_number": 3,
    "age": 31
}
```

```bash
curl -s -X POST http://localhost:8080/api/players/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Jayson Tatum","team":2,"position":"Small Forward","jersey_number":0,"age":26}'
```

**Response `201 Created`:**
```json
{
    "id": 3,
    "name": "Jayson Tatum",
    "team": 2,
    "team_name": "Boston Celtics",
    "position": "Small Forward",
    "jersey_number": 0,
    "age": 26
}
```

#### `GET /api/players/` — List all players

```bash
curl -s http://localhost:8080/api/players/
```

**Response `200 OK`:**
```json
{
    "count": 3,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 3,
            "name": "Jayson Tatum",
            "team": 2,
            "team_name": "Boston Celtics",
            "position": "Small Forward",
            "jersey_number": 0,
            "age": 26
        },
        {
            "id": 2,
            "name": "Anthony Davis",
            "team": 1,
            "team_name": "Los Angeles Lakers",
            "position": "Center",
            "jersey_number": 3,
            "age": 31
        },
        {
            "id": 1,
            "name": "LeBron James",
            "team": 1,
            "team_name": "Los Angeles Lakers",
            "position": "Small Forward",
            "jersey_number": 23,
            "age": 39
        }
    ]
}
```

#### `GET /api/players/1/` — Get single player

```bash
curl -s http://localhost:8080/api/players/1/
```

**Response `200 OK`:**
```json
{
    "id": 1,
    "name": "LeBron James",
    "team": 1,
    "team_name": "Los Angeles Lakers",
    "position": "Small Forward",
    "jersey_number": 23,
    "age": 39
}
```

#### `PATCH /api/players/1/` — Update player

```bash
curl -s -X PATCH http://localhost:8080/api/players/1/ \
  -H "Content-Type: application/json" \
  -d '{"age":40}'
```

**Response `200 OK`:**
```json
{
    "id": 1,
    "name": "LeBron James",
    "team": 1,
    "team_name": "Los Angeles Lakers",
    "position": "Small Forward",
    "jersey_number": 23,
    "age": 40
}
```

---

### Feature 3 — Match Scheduling

#### `POST /api/matches/` — Schedule a match

```bash
curl -s -X POST http://localhost:8080/api/matches/ \
  -H "Content-Type: application/json" \
  -d '{"home_team":1,"away_team":2,"date":"2026-06-01T20:00:00Z","status":"scheduled"}'
```

**Response `201 Created`:**
```json
{
    "id": 1,
    "home_team": 1,
    "home_team_name": "Los Angeles Lakers",
    "away_team": 2,
    "away_team_name": "Boston Celtics",
    "date": "2026-06-01T20:00:00Z",
    "home_score": null,
    "away_score": null,
    "status": "scheduled"
}
```

#### `GET /api/matches/` — List all matches

```bash
curl -s http://localhost:8080/api/matches/
```

**Response `200 OK`:**
```json
{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "home_team": 1,
            "home_team_name": "Los Angeles Lakers",
            "away_team": 2,
            "away_team_name": "Boston Celtics",
            "date": "2026-06-01T20:00:00Z",
            "home_score": null,
            "away_score": null,
            "status": "scheduled"
        }
    ]
}
```

#### `POST /api/matches/1/update_score/` — Post final score

```bash
curl -s -X POST http://localhost:8080/api/matches/1/update_score/ \
  -H "Content-Type: application/json" \
  -d '{"home_score":108,"away_score":95,"status":"completed"}'
```

**Response `200 OK`:**
```json
{
    "id": 1,
    "home_team": 1,
    "home_team_name": "Los Angeles Lakers",
    "away_team": 2,
    "away_team_name": "Boston Celtics",
    "date": "2026-06-01T20:00:00Z",
    "home_score": 108,
    "away_score": 95,
    "status": "completed"
}
```

#### `GET /api/matches/1/` — Verify final result

```bash
curl -s http://localhost:8080/api/matches/1/
```

**Response `200 OK`:**
```json
{
    "id": 1,
    "home_team": 1,
    "home_team_name": "Los Angeles Lakers",
    "away_team": 2,
    "away_team_name": "Boston Celtics",
    "date": "2026-06-01T20:00:00Z",
    "home_score": 108,
    "away_score": 95,
    "status": "completed"
}
```

---

## Running the Test Suite

```bash
cd tests
bash run_all.sh
```

Expected output:
```
[INFO] Checking server at http://localhost:8080 ...
[OK]   Server is reachable.

=== Running: test_teams.sh ===
[PASS] POST   /api/teams/
[PASS] GET    /api/teams/
[PASS] GET    /api/teams/1/
[PASS] PATCH  /api/teams/1/
[PASS] DELETE /api/teams/1/
=== teams: 5/5 PASSED ===

=== Running: test_players.sh ===
[PASS] POST   /api/players/ (LeBron James)
[PASS] POST   /api/players/ (Anthony Davis)
[PASS] POST   /api/players/ (Jayson Tatum)
[PASS] GET    /api/players/
[PASS] GET    /api/players/1/
[PASS] PATCH  /api/players/1/
[PASS] DELETE /api/players/1/
=== players: 7/7 PASSED ===

=== Running: test_matches.sh ===
[PASS] POST   /api/matches/
[PASS] GET    /api/matches/
[PASS] POST   /api/matches/1/update_score/
[PASS] GET    /api/matches/1/
[PASS] DELETE /api/matches/1/
=== matches: 5/5 PASSED ===

==============================
 All 3 suites: 17/17 PASSED
==============================
```

---

## Extraction Pipeline Context

This repository was processed by the **Kompressa V4 10-phase extraction pipeline**:

| Phase | What happened |
|---|---|
| Phase 0 | Repo cloned, Knowledge Graph built (file index, call graph, entry points) |
| Phase 1 | Architecture mapped — 3 Django apps detected as distinct domains |
| Phase 2 | Features discovered: `team-management`, `player-roster`, `match-scheduling` |
| Phase 3 | Dependencies mapped — players depend on teams; matches depend on both |
| Phase 4 | Contracts extracted — input/output types, side effects, error behavior per endpoint |
| Phase 5 | Code extracted into feature packages under `features/` |
| Phase 13 | DNA computed, fidelity score calculated |

Each `features/*/` folder is a **self-contained, importable Python package** ready for use in the Kompressa Feature Bus.
