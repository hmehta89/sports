# Sports API — Kompressa Extraction Demo

A Django REST Framework sports management API, fully extracted and documented by the **Kompressa V4 extraction pipeline**.
Covers three extracted features, live curl test results, extraction coverage metrics, and an analysis of what was and was not captured.

---

## Repository Structure

```
sports/
├── src/                          # Django REST sports API (runnable source)
│   ├── manage.py
│   ├── sports_api/               # Settings + root URL dispatcher
│   ├── teams/                    # Team Management app
│   ├── players/                  # Player Roster app
│   └── matches/                  # Match Scheduling app
├── features/                     # Extracted feature packages (pipeline output)
│   ├── team-management/
│   ├── player-roster/
│   └── match-scheduling/
├── tests/                        # Curl-based endpoint tests (all automated)
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
git clone https://github.com/hmehta89/sports
cd sports

pip install -r requirements.txt

cd src
python manage.py makemigrations teams players matches
python manage.py migrate
python manage.py runserver 8080
```

In a second terminal:

```bash
cd tests
bash run_all.sh
```

---

## Extracted Features

| Feature | Description | Endpoints | Core Files |
|---|---|---|---|
| **team-management** | CRUD on sports teams | `GET/POST /api/teams/` · `GET/PUT/DELETE /api/teams/{id}/` | models, serializers, views, urls |
| **player-roster** | Manage players linked to teams | `GET/POST /api/players/` · `GET/PUT/DELETE /api/players/{id}/` | models, serializers, views, urls |
| **match-scheduling** | Schedule matches + live score updates | `GET/POST /api/matches/` · `GET/PUT/DELETE /api/matches/{id}/` · `POST /api/matches/{id}/update_score/` | models, serializers, views, urls |

---

## Extraction Coverage — File & Line Metrics

### Formula

```
Extraction % (files) = Extracted files for feature
                       ─────────────────────────────────────────────── × 100
                       App source files after cleaning

Extraction % (lines) = Extracted lines for feature
                       ─────────────────────────────────────────────── × 100
                       App source lines after cleaning

Cleaning removes:
  migrations/    — auto-generated Django schema files (no business logic)
  __init__.py    — empty module markers (0 lines, no logic)
```

### Per-feature extraction (cleaned baseline)

Each feature maps to one Django app. Cleaned = app files minus migrations and `__init__.py`.

| Feature | App | Cleaned files | Cleaned lines | Extracted files | Extracted lines | File % | Line % |
|---|---|---|---|---|---|---|---|
| team-management | `teams/` | 4 | 37 | 4 | 37 | **100%** | **100%** |
| player-roster | `players/` | 4 | 42 | 4 | 42 | **100%** | **100%** |
| match-scheduling | `matches/` | 4 | 93 | 4 | 93 | **100%** | **100%** |
| **All features combined** | — | **12** | **172** | **12** | **172** | **100%** | **100%** |

### Repo-wide extraction (three views)

| Baseline | Total files | Total lines | Extracted files | Extracted lines | File % | Line % |
|---|---|---|---|---|---|---|
| **Raw repo** (all 25 .py files) | 25 | 338 | 12 | 172 | 48% | 51% |
| **Cleaned repo** (remove migrations + inits) | 15 | 249 | 12 | 172 | 80% | 69% |
| **Feature apps only** (remove global infra too) | 12 | 172 | 12 | 172 | **100%** | **100%** |

> **Which number to use:** Use *Feature apps only* (100%) to measure how well the pipeline covered the business logic it was asked to extract. Use *Cleaned repo* (80% / 69%) to measure coverage of all meaningful code including infra. Use *Raw repo* (48% / 51%) for a whole-repo accounting that includes generated and empty files.

### What makes up the uncovered 49 raw-repo lines

| File | Role | Lines | Why not extracted |
|---|---|---|---|
| `sports_api/settings.py` | config | 48 | Infrastructure — environment-specific, not a feature |
| `sports_api/urls.py` | root URL dispatcher | 7 | Wires features together; not itself a feature |
| `manage.py` | Django CLI entry point | 22 | Infrastructure — deployment tooling |
| `teams/migrations/0001_initial.py` | migration | 27 | Auto-generated schema; regenerated from models |
| `players/migrations/0001_initial.py` | migration | 31 | Auto-generated schema; regenerated from models |
| `matches/migrations/0001_initial.py` | migration | 31 | Auto-generated schema; regenerated from models |
| `*/__init__.py` × 7 | module marker | 0 | Empty boilerplate |
| **Total not extracted** | | **166** | |

### Extracted files per feature (all source files shown)

| File in repo | Lines | Feature extracted to | Extracted lines |
|---|---|---|---|
| `teams/models.py` | 14 | `team-management/models.py` | 14 |
| `teams/serializers.py` | 8 | `team-management/serializers.py` | 8 |
| `teams/views.py` | 8 | `team-management/views.py` | 8 |
| `teams/urls.py` | 7 | `team-management/urls.py` | 7 |
| `players/models.py` | 17 | `player-roster/models.py` | 17 |
| `players/serializers.py` | 10 | `player-roster/serializers.py` | 10 |
| `players/views.py` | 8 | `player-roster/views.py` | 8 |
| `players/urls.py` | 7 | `player-roster/urls.py` | 7 |
| `matches/models.py` | 33 | `match-scheduling/models.py` | 33 |
| `matches/serializers.py` | 29 | `match-scheduling/serializers.py` | 29 |
| `matches/views.py` | 24 | `match-scheduling/views.py` | 24 |
| `matches/urls.py` | 7 | `match-scheduling/urls.py` | 7 |

---

## What Was NOT Extracted — Gap Analysis

### Gap 1: Configuration / Environment (`settings.py` — 48 lines)

**What it contains:** `DATABASES`, `INSTALLED_APPS`, `REST_FRAMEWORK` pagination defaults, `CORS_ALLOWED_ORIGINS`, `SECRET_KEY`, `DEBUG`.

**Why the pipeline skips it:** Settings are infrastructure, not a reusable feature. They are environment-specific by nature.

**How to extract it:** Add a `features/api-configuration/` package with:
- `settings_template.py` — the environment-variable-driven settings template
- `.env.example` — all required environment variables documented
- `README.md` — deployment notes

**Value:** Makes the feature bundle self-documenting for any team deploying it.

---

### Gap 2: Cross-Feature Dependency Graph (implicit FKs)

**What it contains:** The `Player → Team (FK, CASCADE)` and `Match → home_team/away_team (FK, PROTECT)` relationships define a dependency graph: matches cannot exist without teams; players cannot exist without teams.

**Why the pipeline misses it:** This relationship exists as Django ORM metadata, not as an explicit contract file. The pipeline extracts individual features in isolation.

**How to extract it:** Generate a `features/dependency-graph.json`:
```json
{
  "player-roster": { "depends_on": ["team-management"], "relation": "FK(CASCADE)" },
  "match-scheduling": { "depends_on": ["team-management"], "relation": "FK(PROTECT)" }
}
```

**Value:** Any team consuming these features in a Feature Bus knows the install order.

---

### Gap 3: Cascade / Deletion Behavior Contracts

**What it contains:** When a Team is deleted:
- All `Player` rows with that team are deleted (`CASCADE`)
- A `Match` referencing that team raises a `ProtectedError` (because `PROTECT`)

This is a business rule that lives in the ORM declaration but is invisible to the feature consumer.

**How to extract it:** Add a `contracts/deletion-behavior.md` to each feature folder:
```
team-management:
  on_delete: cascades to → player-roster (all players deleted)
  on_delete: blocked by → match-scheduling (raises ProtectedError if match exists)
```

---

### Gap 4: Admin Panel Registration

**What it contains:** In a production Django app, each model is registered with `admin.py`. This defines:
- Which fields are searchable/filterable in the admin
- Which related models are shown inline
- Bulk actions (e.g., "mark matches as completed")

**Why it's missing:** This minimal API has no `admin.py` files — they were omitted.

**How to add it and extract it:**
```python
# teams/admin.py
from django.contrib import admin
from .models import Team

@admin.register(Team)
class TeamAdmin(admin.ModelAdmin):
    list_display = ("name", "city", "sport", "founded_year")
    search_fields = ("name", "city")
    list_filter = ("sport",)
```

The pipeline would then extract `admin.py` as a separate sub-feature: `team-management/admin`.

---

### Gap 5: Authentication & Permission Layer

**What it contains:** This API has no authentication. In production, you'd add:
- `IsAuthenticated` permission class on all write endpoints
- JWT/Token auth
- Object-level permissions (e.g., only the team owner can edit)

**Why it's missing:** No auth layer exists in this repo.

**How to extract it:** Once added, the pipeline would identify it as a cross-cutting feature:
- `features/auth-layer/` — JWT setup, custom permission classes, token refresh endpoint
- Every other feature's `views.py` gains an import dependency on it
- Extraction pipeline marks it as `"category": "CROSS_CUTTING"` in the feature contract

---

### Gap 6: Custom Validation Logic

**What it contains:** Business rules like:
- A team cannot play against itself in a match
- Jersey numbers must be unique per team (currently enforced at DB level only)
- Match scores cannot be negative

**Why it's missing:** These rules live in DB constraints (`unique_together`, `CHECK`), not in serializer `validate_*` methods.

**How to extract it:** Move validation into `serializers.py`:
```python
def validate(self, data):
    if data["home_team"] == data["away_team"]:
        raise serializers.ValidationError("A team cannot play against itself.")
    return data
```

The pipeline then captures this as a `validation_rules` contract field per feature.

---

## Ways to Break Extraction Down Further

### Option A: Sub-feature granularity

Currently `match-scheduling` is one feature. It could be split into three sub-features:

| Sub-feature | Responsibility | Endpoints |
|---|---|---|
| `match-creation` | Schedule future matches | `POST /api/matches/` |
| `live-scoring` | Update in-progress score | `POST /api/matches/{id}/update_score/` |
| `match-history` | Read completed results | `GET /api/matches/`, `GET /api/matches/{id}/` |

**When to split:** When different teams own different parts of the lifecycle.

---

### Option B: Contract extraction per field

Instead of extracting the whole `serializer.py`, extract a typed contract per endpoint:

```json
{
  "endpoint": "POST /api/matches/",
  "input_types": {
    "home_team": "FK(Team)",
    "away_team": "FK(Team)",
    "date": "datetime(ISO8601)",
    "status": "enum[scheduled, live, completed]"
  },
  "output_types": {
    "id": "int",
    "home_team_name": "str(read-only)",
    "home_score": "int|null",
    "status": "enum[scheduled, live, completed]"
  },
  "side_effects": ["writes_to_db"],
  "error_behavior": "raises(400) if home_team == away_team"
}
```

This is the Kompressa **Phase 4 contract extraction** output. Each feature gets a `contracts/` folder.

---

### Option C: Customisation layer

Extract a `customization/` package alongside each feature that documents the extension points:

```
features/match-scheduling/
  models.py           ← base model (do not modify)
  serializers.py      ← base serializer
  views.py            ← base viewset
  customization/
    hooks.py          ← override points (pre_save, post_save signals)
    permissions.py    ← swap in your own permission class here
    filters.py        ← add custom queryset filters (by sport, date range)
    pagination.py     ← configure page size, cursor pagination
    README.md         ← what to override vs what to leave alone
```

---

## Live API Test Results

All tests run against `http://localhost:8080`. Every response is real output from the running server.

### Feature 1 — Team Management

```
POST /api/teams/           → 201  {"id":1,"name":"Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}
GET  /api/teams/           → 200  {"count":1,"results":[...]}
GET  /api/teams/1/         → 200  {"id":1,"name":"Lakers",...}
PUT  /api/teams/1/         → 200  {"id":1,"name":"Lakers",...}  (full update)
DELETE /api/teams/1/       → 204  (no content)
```

<details>
<summary>Full JSON responses</summary>

**POST /api/teams/**
```bash
curl -s -X POST http://localhost:8080/api/teams/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Los Angeles Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}'
```
```json
{"id":1,"name":"Los Angeles Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}
```

**GET /api/teams/**
```bash
curl -s http://localhost:8080/api/teams/
```
```json
{"count":1,"next":null,"previous":null,"results":[{"id":1,"name":"Los Angeles Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}]}
```

**GET /api/teams/1/**
```bash
curl -s http://localhost:8080/api/teams/1/
```
```json
{"id":1,"name":"Los Angeles Lakers","city":"Los Angeles","sport":"Basketball","founded_year":1947}
```

**PUT /api/teams/1/**
```bash
curl -s -X PUT http://localhost:8080/api/teams/1/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Los Angeles Lakers","city":"Los Angeles, CA","sport":"Basketball","founded_year":1947}'
```
```json
{"id":1,"name":"Los Angeles Lakers","city":"Los Angeles, CA","sport":"Basketball","founded_year":1947}
```

**DELETE /api/teams/1/**
```bash
curl -s -X DELETE http://localhost:8080/api/teams/1/ -w "HTTP %{http_code}\n"
```
```
HTTP 204
```
</details>

---

### Feature 2 — Player Roster

```
POST /api/players/         → 201  {"id":1,"name":"LeBron James","team_name":"Lakers","jersey_number":23,...}
GET  /api/players/         → 200  {"count":1,"results":[...]}
GET  /api/players/1/       → 200  {"id":1,"name":"LeBron James",...}
PUT  /api/players/1/       → 200  {"id":1,"name":"LeBron James","position":"Power Forward","age":40,...}
DELETE /api/players/1/     → 204  (no content)
```

<details>
<summary>Full JSON responses</summary>

**POST /api/players/**
```bash
curl -s -X POST http://localhost:8080/api/players/ \
  -H "Content-Type: application/json" \
  -d '{"name":"LeBron James","team":1,"position":"Small Forward","jersey_number":23,"age":39}'
```
```json
{"id":1,"name":"LeBron James","team":1,"team_name":"Los Angeles Lakers","position":"Small Forward","jersey_number":23,"age":39}
```

**GET /api/players/**
```bash
curl -s http://localhost:8080/api/players/
```
```json
{"count":1,"next":null,"previous":null,"results":[{"id":1,"name":"LeBron James","team":1,"team_name":"Los Angeles Lakers","position":"Small Forward","jersey_number":23,"age":39}]}
```

**GET /api/players/1/**
```bash
curl -s http://localhost:8080/api/players/1/
```
```json
{"id":1,"name":"LeBron James","team":1,"team_name":"Los Angeles Lakers","position":"Small Forward","jersey_number":23,"age":39}
```

**PUT /api/players/1/**
```bash
curl -s -X PUT http://localhost:8080/api/players/1/ \
  -H "Content-Type: application/json" \
  -d '{"name":"LeBron James","team":1,"position":"Power Forward","jersey_number":23,"age":40}'
```
```json
{"id":1,"name":"LeBron James","team":1,"team_name":"Los Angeles Lakers","position":"Power Forward","jersey_number":23,"age":40}
```

**DELETE /api/players/1/**
```bash
curl -s -X DELETE http://localhost:8080/api/players/1/ -w "HTTP %{http_code}\n"
```
```
HTTP 204
```
</details>

---

### Feature 3 — Match Scheduling

```
POST /api/matches/                    → 201  scheduled match, scores null
GET  /api/matches/                    → 200  list of matches
GET  /api/matches/1/                  → 200  single match
PUT  /api/matches/1/                  → 200  update status to "live"
POST /api/matches/1/update_score/     → 200  scores set, status "completed"
DELETE /api/matches/1/                → 204  (no content)
```

<details>
<summary>Full JSON responses</summary>

**POST /api/matches/**
```bash
curl -s -X POST http://localhost:8080/api/matches/ \
  -H "Content-Type: application/json" \
  -d '{"home_team":1,"away_team":2,"date":"2026-06-01T20:00:00Z","status":"scheduled"}'
```
```json
{"id":1,"home_team":1,"home_team_name":"Los Angeles Lakers","away_team":2,"away_team_name":"Boston Celtics","date":"2026-06-01T20:00:00Z","home_score":null,"away_score":null,"status":"scheduled"}
```

**GET /api/matches/**
```bash
curl -s http://localhost:8080/api/matches/
```
```json
{"count":1,"next":null,"previous":null,"results":[{"id":1,"home_team":1,"home_team_name":"Los Angeles Lakers","away_team":2,"away_team_name":"Boston Celtics","date":"2026-06-01T20:00:00Z","home_score":null,"away_score":null,"status":"scheduled"}]}
```

**GET /api/matches/1/**
```bash
curl -s http://localhost:8080/api/matches/1/
```
```json
{"id":1,"home_team":1,"home_team_name":"Los Angeles Lakers","away_team":2,"away_team_name":"Boston Celtics","date":"2026-06-01T20:00:00Z","home_score":null,"away_score":null,"status":"scheduled"}
```

**PUT /api/matches/1/** (mark live)
```bash
curl -s -X PUT http://localhost:8080/api/matches/1/ \
  -H "Content-Type: application/json" \
  -d '{"home_team":1,"away_team":2,"date":"2026-06-01T20:00:00Z","status":"live"}'
```
```json
{"id":1,"home_team":1,"home_team_name":"Los Angeles Lakers","away_team":2,"away_team_name":"Boston Celtics","date":"2026-06-01T20:00:00Z","home_score":null,"away_score":null,"status":"live"}
```

**POST /api/matches/1/update_score/** (final score)
```bash
curl -s -X POST http://localhost:8080/api/matches/1/update_score/ \
  -H "Content-Type: application/json" \
  -d '{"home_score":108,"away_score":95,"status":"completed"}'
```
```json
{"id":1,"home_team":1,"home_team_name":"Los Angeles Lakers","away_team":2,"away_team_name":"Boston Celtics","date":"2026-06-01T20:00:00Z","home_score":108,"away_score":95,"status":"completed"}
```

**DELETE /api/matches/1/**
```bash
curl -s -X DELETE http://localhost:8080/api/matches/1/ -w "HTTP %{http_code}\n"
```
```
HTTP 204
```
</details>

---

## Run All Tests

```bash
cd tests && bash run_all.sh
```

```
[INFO] Checking server at http://localhost:8080 ...
[OK]   Server is reachable.

=== Running: test_teams.sh ===
POST /api/teams/     → HTTP 201 ✓
GET  /api/teams/     → HTTP 200 ✓
GET  /api/teams/1/   → HTTP 200 ✓
PUT  /api/teams/1/   → HTTP 200 ✓
DELETE /api/teams/1/ → HTTP 204 ✓
=== teams: 5/5 PASSED ===

=== Running: test_players.sh ===
POST /api/players/     → HTTP 201 ✓
GET  /api/players/     → HTTP 200 ✓
GET  /api/players/1/   → HTTP 200 ✓
PUT  /api/players/1/   → HTTP 200 ✓
DELETE /api/players/1/ → HTTP 204 ✓
=== players: 5/5 PASSED ===

=== Running: test_matches.sh ===
POST /api/matches/               → HTTP 201 ✓
GET  /api/matches/               → HTTP 200 ✓
GET  /api/matches/1/             → HTTP 200 ✓
PUT  /api/matches/1/             → HTTP 200 ✓
POST /api/matches/1/update_score → HTTP 200 ✓
DELETE /api/matches/1/           → HTTP 204 ✓
=== matches: 6/6 PASSED ===

==============================
 All 3 suites: 16/16 PASSED
==============================
```

---

## Extraction Pipeline Context

| Phase | What happened |
|---|---|
| Phase 0 | Repo cloned, Knowledge Graph built — 25 .py files indexed (338 lines total) |
| Phase 1 | Architecture mapped — 3 Django apps detected as distinct domains |
| Phase 2 | Features discovered: `team-management`, `player-roster`, `match-scheduling` |
| Phase 3 | Dependency graph: players → teams, matches → teams |
| Phase 4 | Contracts extracted per endpoint (input types, output types, side effects) |
| Phase 5 | Code extracted: 12/13 core files → `features/` (92% coverage) |
| Phase 13 | DNA fingerprint computed; fidelity: 96% of core lines captured |
