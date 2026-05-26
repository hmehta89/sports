# Team Management Feature

Manages sports teams. Supports full CRUD operations via a REST API.

## Model

| Field          | Type              | Notes                  |
|----------------|-------------------|------------------------|
| `id`           | integer (auto)    | Primary key            |
| `name`         | string (100)      | Unique team name       |
| `city`         | string (100)      | City of the team       |
| `sport`        | string (50)       | Sport type (e.g. NBA)  |
| `founded_year` | positive integer  | Year team was founded  |

## Endpoints

| Method | URL               | Description          |
|--------|-------------------|----------------------|
| GET    | `/api/teams/`     | List all teams       |
| POST   | `/api/teams/`     | Create a new team    |
| GET    | `/api/teams/{id}/`| Retrieve a team      |
| PUT    | `/api/teams/{id}/`| Update a team        |
| PATCH  | `/api/teams/{id}/`| Partial update       |
| DELETE | `/api/teams/{id}/`| Delete a team        |

## Example Payload

**POST /api/teams/**

```json
{
  "name": "Lakers",
  "city": "Los Angeles",
  "sport": "Basketball",
  "founded_year": 1947
}
```

**Response (201 Created)**

```json
{
  "id": 1,
  "name": "Lakers",
  "city": "Los Angeles",
  "sport": "Basketball",
  "founded_year": 1947
}
```

## Files

- `models.py` — `Team` Django model
- `serializers.py` — `TeamSerializer` (ModelSerializer)
- `views.py` — `TeamViewSet` (ModelViewSet)
- `urls.py` — DRF router registration

## Integration

Register in project `urls.py`:

```python
path('api/', include('teams.urls')),
```

Add `'teams'` to `INSTALLED_APPS` and run:

```bash
python manage.py makemigrations teams
python manage.py migrate
```
