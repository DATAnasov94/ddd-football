# дДд Football

Football scores, live match data, statistics and match predictions in one application.

## About

**дДд Football** is a football application for following live matches, results, fixtures, competitions and team statistics.

The first version of the application will provide football scores and match information for free. A premium version with match predictions and advanced analysis is planned for a later development stage.

The project is currently under active development.

## Current functionality

- FastAPI backend
- API-Football integration
- Matches for the current date
- Matches for a selected date
- Europe/Sofia timezone support
- In-memory response caching
- API error handling
- Validation of dates available under the API plan
- Environment-based API configuration
- Automatic Swagger documentation

## Planned features

### Free version

- Live football scores
- Upcoming and completed matches
- Match events
- Goals, cards and substitutions
- League standings
- Team information
- Match statistics
- Favourite teams and competitions
- Match notifications
- Bulgarian and English interface

### Premium version

- Match predictions
- Home, draw and away probabilities
- Over/under goal predictions
- Both teams to score probabilities
- Team form comparison
- Advanced match analysis
- Historical prediction performance
- Independent prediction model

## Technology stack

### Backend

- Python
- FastAPI
- HTTPX
- API-Football
- PostgreSQL — planned
- Redis — planned

### Client application

- Flutter — planned
- Android
- iOS
- Web

## Project structure

```text
ddd-football/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── routes/
│   │   ├── core/
│   │   ├── schemas/
│   │   ├── services/
│   │   └── main.py
│   ├── .env.example
│   └── requirements.txt
├── mobile/
├── .gitignore
└── README.md
```

## Backend setup

### 1. Clone the repository

```bash
git clone https://github.com/DATAnasov94/ddd-football.git
```

```bash
cd ddd-football/backend
```

### 2. Create a Python virtual environment

```bash
python3 -m venv .venv
```

Activate it on macOS or Linux:

```bash
source .venv/bin/activate
```

Activate it on Windows:

```powershell
.venv\Scripts\activate
```

### 3. Install the dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure the environment

Copy the example environment file:

```bash
cp .env.example .env
```

On Windows:

```powershell
copy .env.example .env
```

Open `.env` and add your API-Football key:

```env
API_FOOTBALL_KEY=your_api_key_here
API_FOOTBALL_BASE_URL=https://v3.football.api-sports.io
```

Never commit a real API key to GitHub.

### 5. Start the backend

```bash
uvicorn app.main:app --reload
```

The backend will be available at:

```text
http://127.0.0.1:8000
```

Swagger documentation:

```text
http://127.0.0.1:8000/docs
```

## Available endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Application information |
| `GET` | `/api/health` | Backend health check |
| `GET` | `/api/matches/today` | Matches for the current date |
| `GET` | `/api/matches?match_date=YYYY-MM-DD` | Matches for a selected date |

## Example response

```json
{
  "date": "2026-09-16",
  "timezone": "Europe/Sofia",
  "total": 418,
  "matches": [],
  "cached": true
}
```

## Caching

Match responses are temporarily stored in an in-memory cache.

This reduces the number of requests sent to API-Football and protects the daily API request limit.

The current cache duration is five minutes.

## API limitations

The project currently uses the free API-Football plan.

The free plan provides access to a limited date range and a limited number of API requests. The backend validates selected dates and returns a clear error when a requested date is unavailable.

These limitations will be expanded when the application moves to a production API plan.

## Security

Sensitive configuration is stored in a local `.env` file.

The real `.env` file is excluded from Git through `.gitignore`. Only `.env.example`, containing placeholder values, is included in the repository.

## Roadmap

- [x] Create the FastAPI backend
- [x] Connect API-Football
- [x] Retrieve matches for the current date
- [x] Retrieve matches by selected date
- [x] Add in-memory caching
- [x] Add date validation
- [x] Add API error handling
- [ ] Add competition filtering and ordering
- [ ] Add live-match filtering
- [ ] Add detailed match information
- [ ] Add match events and statistics
- [ ] Add league standings
- [ ] Create the Flutter application
- [ ] Add user accounts
- [ ] Add favourite teams and competitions
- [ ] Add push notifications
- [ ] Add premium predictions
- [ ] Add paid subscriptions
- [ ] Develop an independent prediction model

## Author

**Dobromir Atanasov**

NOC Engineer and software developer based in Varna, Bulgaria.

GitHub: [DATAnasov94](https://github.com/DATAnasov94)

## Project status

This project is in an early development stage. Features, API responses and the project structure may change during development.

## Copyright

Copyright © 2026 Dobromir Atanasov. All rights reserved.