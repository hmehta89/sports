# Player Roster Feature

Manages player rosters for sports teams. Each player belongs to a team and has a unique jersey number within that team.

## Model

| Field           | Type              | Notes                              |
|-----------------|-------------------|------------------------------------|
| `id`            | integer (auto)    | Primary key                        |
| `name`          | string (100)      | Player full name                   |
| `team`          | FK → Team         | Team the player belongs to         |
| `position`      | string (50)       | Playing position (e.g. Small Forward) |
| `jersey_number` | positive integer  | Unique per team                    |
| `age`           | positive integer  | Player age                         |

## Endpoints

| Method | URL                  | Description           |
|--------|----------------------|-----------------------|
| GET    | `/api/players/`      | List all players      |
| POST   | `/api/players/`      | Add a new player      |
| GET    | `/api/players/{id}/` | Retrieve a player     |
| PUT    | `/api/players/{id}/` | Update a player       |
| PATCH  | `/api/players/{id}/` | Partial update        |
| DELETE | `/api/players/{id}/` | Remove a player       |

## Example Payload

**POST /api/players/**

```json
{
  "name": "LeBron James",
  "team": 1,
  "position": "Small Forward",
  "jersey_number": 23,
  "age": 39
}
```

**Response (201 Created)**

```json
{
  "id": 1,
  "name": "LeBron James",
  "team": 1,
  "team_name": "Lakers",
  "position": "Small Forward",
  "jersey_number": 23,
  "age": 39
}
```

## Files

- `models.py` — `Player` Django model with FK to `Team`
- `serializers.py` — `PlayerSerializer` with read-only `team_name`
- `views.py` — `PlayerViewSet` (ModelViewSet) with `select_related` optimization
- `urls.py` — DRF router registration

## Integration

Register in project `urls.py`:

```python
path('api/', include('players.urls')),
```

Add `'players'` to `INSTALLED_APPS` and run:

```bash
python manage.py makemigrations players
python manage.py migrate
```
