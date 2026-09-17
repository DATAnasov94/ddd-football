# дДд Football

A cross-platform football application for live scores, match results, competitions, standings and future premium match predictions.

## Project overview

**дДд Football** is being developed as a free football scores application with an optional premium prediction service.

The project currently includes:

* a Python and FastAPI backend;
* integration with API-Football;
* a Flutter client for web, Android, iOS and macOS;
* live matches, historical results and match details;
* competition filtering and league standings;
* backend caching and API error handling.

The project is under active development.

## Current functionality

### Backend

* FastAPI application
* API-Football integration
* Environment-based API configuration
* Matches for the current date
* Matches for a selected date
* Live football matches
* Featured competition filtering
* Match ordering by competition priority
* Detailed match information
* Match events, goals, cards and substitutions
* Team line-ups and player data when available
* Featured competitions
* League standings
* Europe/Sofia timezone support
* Date and parameter validation
* In-memory TTL caching
* API error handling
* CORS support for local Flutter development
* Automatic Swagger documentation

### Flutter application

* Dark football-oriented interface
* Real football data from the FastAPI backend
* Team and competition logos
* Match times and results
* Live-match indicators
* Match status information
* Match details screen
* Match event timeline
* Venue information
* Date selection
* Pull-to-refresh
* Loading, empty and error states
* Bottom navigation
* Matches section
* Live matches section
* Prepared competitions section
* Web support through Chrome

## Application sections

### Matches

The Matches screen provides access to the dates currently available under the free API-Football plan:

* two days ago;
* yesterday;
* today.

Users can view upcoming and completed matches and open the details of an individual fixture.

### Live

The Live section displays matches currently in progress.

Live data is temporarily cached to protect the API request allowance of the free API-Football plan.

### Competitions

The Competitions section is prepared for featured competitions and league standings.

The backend endpoints are already implemented. The full Flutter interface for standings is part of the next development stage.

## Technology stack

### Backend

* Python
* FastAPI
* HTTPX
* API-Football
* Uvicorn
* Python Dotenv

Planned backend technologies:

* PostgreSQL
* Redis
* JWT authentication

### Client

* Flutter
* Dart
* Material 3
* HTTP package

Supported and planned platforms:

* Web
* Android
* iOS
* macOS

## Project structure

```text
ddd-football/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── routes/
│   │   │       ├── leagues.py
│   │   │       └── matches.py
│   │   ├── core/
│   │   │   ├── cache.py
│   │   │   ├── config.py
│   │   │   └── leagues.py
│   │   ├── schemas/
│   │   ├── services/
│   │   │   └── football_api.py
│   │   └── main.py
│   ├── .env.example
│   └── requirements.txt
├── mobile/
│   ├── android/
│   ├── ios/
│   ├── macos/
│   ├── web/
│   ├── lib/
│   │   ├── core/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── main.dart
│   └── pubspec.yaml
├── .gitignore
└── README.md
```

## Backend setup

### 1. Clone the repository

```bash
git clone https://github.com/DATAnasov94/ddd-football.git
cd ddd-football/backend
```

### 2. Create a virtual environment

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

Copy the example configuration:

```bash
cp .env.example .env
```

Add your API-Football configuration:

```env
API_FOOTBALL_KEY=your_api_key_here
API_FOOTBALL_BASE_URL=https://v3.football.api-sports.io
```

Never commit a real API key to GitHub.

### 5. Start the backend

```bash
uvicorn app.main:app --reload
```

Backend URL:

```text
http://127.0.0.1:8000
```

Swagger documentation:

```text
http://127.0.0.1:8000/docs
```

## Flutter setup

### 1. Open the Flutter project

```bash
cd ddd-football/mobile
```

### 2. Install the dependencies

```bash
flutter pub get
```

### 3. Verify the project

```bash
flutter analyze
```

### 4. Start the web application

Make sure the FastAPI backend is already running.

Then execute:

```bash
flutter run -d chrome
```

## Backend endpoints

### System

| Method | Endpoint      | Description             |
| ------ | ------------- | ----------------------- |
| `GET`  | `/`           | Application information |
| `GET`  | `/api/health` | Backend health check    |

### Matches

| Method | Endpoint                             | Description                   |
| ------ | ------------------------------------ | ----------------------------- |
| `GET`  | `/api/matches/today`                 | Matches for the current date  |
| `GET`  | `/api/matches?match_date=YYYY-MM-DD` | Matches for a selected date   |
| `GET`  | `/api/matches/live`                  | Matches currently in progress |
| `GET`  | `/api/matches/{fixture_id}`          | Detailed match information    |

Optional match filters:

```text
featured_only=true
league_id=39
```

Example:

```text
/api/matches/today?featured_only=true
```

### Competitions

| Method | Endpoint                             | Description           |
| ------ | ------------------------------------ | --------------------- |
| `GET`  | `/api/leagues/featured`              | Featured competitions |
| `GET`  | `/api/leagues/{league_id}/standings` | Competition standings |

Example:

```text
/api/leagues/39/standings?season=2024
```

## Featured competitions

The initial featured competition list includes:

* Bulgarian First League
* UEFA Champions League
* UEFA Europa League
* UEFA Conference League
* Premier League
* La Liga
* Serie A
* Bundesliga
* Ligue 1
* FIFA World Cup
* UEFA European Championship

## Caching

The backend uses an in-memory TTL cache to reduce external API usage.

Current caching behaviour:

* match lists: 5 minutes;
* live matches: 5 minutes under the free API plan;
* upcoming match details: 5 minutes;
* live match details: 1 minute;
* completed match details: 24 hours;
* league standings: 1 hour.

The live cache interval will be reduced when the project moves to a paid API plan.

The in-memory cache is cleared when the backend is restarted. Redis is planned for the production version.

## API plan limitations

The project currently uses the free API-Football plan.

The free plan has limitations related to:

* available dates;
* available seasons;
* historical data;
* number of daily requests.

The current application handles the available date range and uses caching to protect the daily request allowance.

A paid API plan is planned before the application is released publicly.

## Security

Sensitive values are stored in:

```text
backend/.env
```

The real `.env` file is excluded from Git.

The repository contains only:

```text
backend/.env.example
```

with placeholder values.

API keys must remain on the backend and must never be embedded in the Flutter application.

## Development roadmap

### Completed

* [x] Create the FastAPI backend
* [x] Connect API-Football
* [x] Retrieve matches for the current date
* [x] Retrieve matches by selected date
* [x] Add live matches
* [x] Add featured competition filtering
* [x] Add match ordering
* [x] Add detailed match endpoint
* [x] Add match events and line-ups
* [x] Add featured competitions endpoint
* [x] Add league standings endpoint
* [x] Add in-memory caching
* [x] Add API error handling
* [x] Add CORS support
* [x] Create the Flutter project
* [x] Connect Flutter to FastAPI
* [x] Create the matches dashboard
* [x] Add team and competition logos
* [x] Add match details navigation
* [x] Add match event timeline
* [x] Add bottom navigation
* [x] Add live matches screen
* [x] Add match date selection

### Next stages

* [ ] Complete the Flutter competitions screen
* [ ] Add the Flutter league standings table
* [ ] Improve responsive desktop layout
* [ ] Add Android Studio and Android SDK
* [ ] Test on an Android emulator and physical device
* [ ] Complete Xcode and CocoaPods configuration
* [ ] Test on iOS Simulator
* [ ] Add favourite teams and competitions
* [ ] Add user accounts
* [ ] Add push notifications
* [ ] Add persistent PostgreSQL storage
* [ ] Add Redis caching
* [ ] Add premium match predictions
* [ ] Add subscriptions
* [ ] Develop an independent prediction model

## Planned premium functionality

The premium version is planned to include:

* home, draw and away probabilities;
* over/under goal predictions;
* both teams to score probabilities;
* team form comparison;
* advanced match analysis;
* prediction history;
* historical prediction performance;
* an independent prediction model.

Predictions will be presented as statistical probabilities and analysis, not as guaranteed results.

## Author

**Dobromir Atanasov**

NOC Engineer and software developer based in Varna, Bulgaria.

GitHub: [DATAnasov94](https://github.com/DATAnasov94)

## Project status

This project is in an active early-development stage. Features, API responses and project structure may change during development.

## Copyright

Copyright © 2026 Dobromir Atanasov. All rights reserved.
