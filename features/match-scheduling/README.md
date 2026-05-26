# Match Scheduling Feature

Manages game scheduling between teams. Tracks scores and match status with an extra action endpoint for live score updates.

## Model

| Field        | Type              | Notes                                       |
|--------------|-------------------|---------------------------------------------|
| `id`         | integer (auto)    | Primary key                                 |
| `home_team`  | FK → Team         | The home team                               |
| `away_team`  | FK → Team         | The away team (must differ from home_team)  |
| `date`       | datetime          | Scheduled or played datetime (UTC)          |
| `home_score` | positive integer  | Nullable until match is played              |
| `away_score` | positive integer  | Nullable until match is played              |
| `status`     | string (choice)   | `scheduled` / `live` / `completed`          |

## Endpoints

| Method | URL                                  | Description                    |
|--------|--------------------------------------|--------------------------------|
| GET    | `/api/matches/`                      | List all matches               |
| POST   | `/api/matches/`                      | Schedule a new match           |
| GET    | `/api/matches/{id}/`                 | Retrieve a match               |
| PUT    | `/api/matches/{id}/`                 | Update a match                 |
| PATCH  | `/api/matches/{id}/`                 | Partial update                 |
| DELETE | `/api/matches/{id}/`                 | Delete a match                 |
| POST   | `/api/matches/{id}/update_score/`    | Update score + status          |

## Example Payloads

**POST /api/matches/**

```json
{
  "home_team": 1,
  "away_team": 2,
  "date": "2025-06-15T20:00:00Z",
  "status": "scheduled"
}
```

**Response (201 Created)**

```json
{
  "id": 1,
  "home_team": 1,
  "home_team_name": "Lakers",
  "away_team": 2,
  "away_team_name": "Celtics",
  "date": "2025-06-15T20:00:00Z",
  "home_score": null,
  "away_score": null,
  "status": "scheduled"
}
```

**POST /api/matches/1/update_score/**

```json
{
  "home_score": 112,
  "away_score": 108,
  "status": "completed"
}
```

**Response (200 OK)**

```json
{
  "id": 1,
  "home_team": 1,
  "home_team_name": "Lakers",
  "away_team": 2,
  "away_team_name": "Celtics",
  "date": "2025-06-15T20:00:00Z",
  "home_score": 112,
  "away_score": 108,
  "status": "completed"
}
```

## Files

- `models.py` — `Match` model with two Team FKs and status choices
- `serializers.py` — `MatchSerializer` + `UpdateScoreSerializer`
- `views.py` — `MatchViewSet` with `update_score` extra action
- `urls.py` — DRF router registration

## Integration

Register in project `urls.py`:

```python
path('api/', include('matches.urls')),
```

Add `'matches'` to `INSTALLED_APPS` and run:

```bash
python manage.py makemigrations matches
python manage.py migrate
```
