from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo
from typing import Optional
from fastapi import APIRouter, HTTPException, Path, Query

from app.core.cache import cache
from app.services.football_api import (
    FootballAPIError,
    football_api_client,
)
from app.core.leagues import DEFAULT_PRIORITY, FEATURED_LEAGUES


router = APIRouter(
    prefix="/api/matches",
    tags=["Matches"],
)

SOFIA_TIMEZONE = ZoneInfo("Europe/Sofia")


def format_match(item: dict) -> dict:
    fixture = item.get("fixture", {})
    league = item.get("league", {})
    teams = item.get("teams", {})
    goals = item.get("goals", {})
    score = item.get("score", {})

    return {
        "id": fixture.get("id"),
        "date": fixture.get("date"),
        "timestamp": fixture.get("timestamp"),
        "timezone": fixture.get("timezone"),
        "venue": {
            "name": fixture.get("venue", {}).get("name"),
            "city": fixture.get("venue", {}).get("city"),
        },
        "status": {
            "long": fixture.get("status", {}).get("long"),
            "short": fixture.get("status", {}).get("short"),
            "elapsed": fixture.get("status", {}).get("elapsed"),
        },
        "league": {
            "id": league.get("id"),
            "name": league.get("name"),
            "country": league.get("country"),
            "logo": league.get("logo"),
            "flag": league.get("flag"),
            "season": league.get("season"),
            "round": league.get("round"),
        },
        "home_team": {
            "id": teams.get("home", {}).get("id"),
            "name": teams.get("home", {}).get("name"),
            "logo": teams.get("home", {}).get("logo"),
            "winner": teams.get("home", {}).get("winner"),
        },
        "away_team": {
            "id": teams.get("away", {}).get("id"),
            "name": teams.get("away", {}).get("name"),
            "logo": teams.get("away", {}).get("logo"),
            "winner": teams.get("away", {}).get("winner"),
        },
        "goals": {
            "home": goals.get("home"),
            "away": goals.get("away"),
        },
        "score": score,
    }
def format_match_details(item: dict) -> dict:
    match = format_match(item)

    events = []

    for event in item.get("events", []):
        events.append(
            {
                "time": {
                    "elapsed": event.get("time", {}).get("elapsed"),
                    "extra": event.get("time", {}).get("extra"),
                },
                "team": {
                    "id": event.get("team", {}).get("id"),
                    "name": event.get("team", {}).get("name"),
                    "logo": event.get("team", {}).get("logo"),
                },
                "player": {
                    "id": event.get("player", {}).get("id"),
                    "name": event.get("player", {}).get("name"),
                },
                "assist": {
                    "id": event.get("assist", {}).get("id"),
                    "name": event.get("assist", {}).get("name"),
                },
                "type": event.get("type"),
                "detail": event.get("detail"),
                "comments": event.get("comments"),
            }
        )

    statistics = []

    for team_statistics in item.get("statistics", []):
        statistics.append(
            {
                "team": {
                    "id": team_statistics.get("team", {}).get("id"),
                    "name": team_statistics.get("team", {}).get("name"),
                    "logo": team_statistics.get("team", {}).get("logo"),
                },
                "statistics": team_statistics.get("statistics", []),
            }
        )

    lineups = []

    for lineup in item.get("lineups", []):
        lineups.append(
            {
                "team": {
                    "id": lineup.get("team", {}).get("id"),
                    "name": lineup.get("team", {}).get("name"),
                    "logo": lineup.get("team", {}).get("logo"),
                },
                "coach": {
                    "id": lineup.get("coach", {}).get("id"),
                    "name": lineup.get("coach", {}).get("name"),
                    "photo": lineup.get("coach", {}).get("photo"),
                },
                "formation": lineup.get("formation"),
                "start_xi": lineup.get("startXI", []),
                "substitutes": lineup.get("substitutes", []),
            }
        )

    players = []

    for team_players in item.get("players", []):
        players.append(
            {
                "team": {
                    "id": team_players.get("team", {}).get("id"),
                    "name": team_players.get("team", {}).get("name"),
                    "logo": team_players.get("team", {}).get("logo"),
                },
                "players": team_players.get("players", []),
            }
        )

    return {
        **match,
        "events": events,
        "statistics": statistics,
        "lineups": lineups,
        "players": players,
    }

def filter_and_sort_matches(
    result: dict,
    league_id: Optional[int] = None,
    featured_only: bool = False,
) -> dict:
    matches = list(result.get("matches", []))
    original_total = len(matches)

    if league_id is not None:
        matches = [
            match
            for match in matches
            if match.get("league", {}).get("id") == league_id
        ]

    if featured_only:
        matches = [
            match
            for match in matches
            if match.get("league", {}).get("id") in FEATURED_LEAGUES
        ]

    matches.sort(
        key=lambda match: (
            FEATURED_LEAGUES.get(
                match.get("league", {}).get("id"),
                {},
            ).get("priority", DEFAULT_PRIORITY),
            match.get("date") or "",
        )
    )

    return {
        **result,
        "original_total": original_total,
        "total": len(matches),
        "matches": matches,
    }


async def load_matches(selected_date: date) -> dict:
    today = datetime.now(SOFIA_TIMEZONE).date()
    earliest_allowed_date = today - timedelta(days=2)

    if selected_date < earliest_allowed_date or selected_date > today:
        raise HTTPException(
            status_code=400,
            detail={
                "message": (
                    "Безплатният API-Football план няма достъп "
                    "до избраната дата."
                ),
                "selected_date": selected_date.isoformat(),
                "available_from": earliest_allowed_date.isoformat(),
                "available_to": today.isoformat(),
            },
        )

    date_string = selected_date.isoformat()
    cache_key = f"matches:date:{date_string}"

    cached_result = await cache.get(cache_key)

    if cached_result is not None:
        return {
            **cached_result,
            "cached": True,
        }

    try:
        fixtures = await football_api_client.get_fixtures(
            date=date_string,
            timezone="Europe/Sofia",
        )
    except FootballAPIError as exc:
        raise HTTPException(
            status_code=502,
            detail=str(exc),
        ) from exc

    matches = [format_match(item) for item in fixtures]

    result = {
        "date": date_string,
        "timezone": "Europe/Sofia",
        "total": len(matches),
        "matches": matches,
    }

    await cache.set(
        key=cache_key,
        value=result,
        ttl_seconds=300,
    )

    return {
        **result,
        "cached": False,
    }


@router.get("")
async def get_matches_by_date(
    match_date: date = Query(
        ...,
        description="Дата във формат YYYY-MM-DD",
        examples=["2026-09-16"],
    ),
    league_id: Optional[int] = Query(
        None,
        description="Филтриране по API-Football league ID",
        examples=[39],
    ),
    featured_only: bool = Query(
        False,
        description="Показва само приоритетните първенства",
    ),
):
    result = await load_matches(match_date)

    return filter_and_sort_matches(
        result=result,
        league_id=league_id,
        featured_only=featured_only,
    )


@router.get("/today")
async def get_today_matches(
    league_id: Optional[int] = Query(
        None,
        description="Филтриране по API-Football league ID",
        examples=[39],
    ),
    featured_only: bool = Query(
        False,
        description="Показва само приоритетните първенства",
    ),
):
    today = datetime.now(SOFIA_TIMEZONE).date()
    result = await load_matches(today)

    return filter_and_sort_matches(
        result=result,
        league_id=league_id,
        featured_only=featured_only,
    )
@router.get("/live")
async def get_live_matches(
    league_id: Optional[int] = Query(
        None,
        description="Филтриране по API-Football league ID",
        examples=[39],
    ),
    featured_only: bool = Query(
        False,
        description="Показва само приоритетните първенства",
    ),
):
    cache_key = "matches:live"

    cached_result = await cache.get(cache_key)

    if cached_result is not None:
        return filter_and_sort_matches(
            result={
                **cached_result,
                "cached": True,
            },
            league_id=league_id,
            featured_only=featured_only,
        )

    try:
        fixtures = await football_api_client.get_live_fixtures(
            timezone="Europe/Sofia",
        )
    except FootballAPIError as exc:
        raise HTTPException(
            status_code=502,
            detail=str(exc),
        ) from exc

    matches = [format_match(item) for item in fixtures]

    result = {
        "type": "live",
        "timezone": "Europe/Sofia",
        "updated_at": datetime.now(SOFIA_TIMEZONE).isoformat(),
        "total": len(matches),
        "matches": matches,
    }

    await cache.set(
        key=cache_key,
        value=result,
        ttl_seconds=300,
    )

    return filter_and_sort_matches(
        result={
            **result,
            "cached": False,
        },
        league_id=league_id,
        featured_only=featured_only,
    )

@router.get("/{fixture_id}")
async def get_match_details(
    fixture_id: int = Path(
        ...,
        ge=1,
        description="API-Football fixture ID",
        examples=[1511694],
    ),
):
    cache_key = f"match:details:{fixture_id}"

    cached_result = await cache.get(cache_key)

    if cached_result is not None:
        return {
            **cached_result,
            "cached": True,
        }

    try:
        fixture = await football_api_client.get_fixture_by_id(
            fixture_id=fixture_id,
        )
    except FootballAPIError as exc:
        error_message = str(exc)

        if "Не е намерен мач" in error_message:
            raise HTTPException(
                status_code=404,
                detail=error_message,
            ) from exc

        raise HTTPException(
            status_code=502,
            detail=error_message,
        ) from exc

    result = format_match_details(fixture)

    status_short = result.get("status", {}).get("short")

    live_statuses = {
        "1H",
        "HT",
        "2H",
        "ET",
        "BT",
        "P",
        "SUSP",
        "INT",
        "LIVE",
    }

    finished_statuses = {
        "FT",
        "AET",
        "PEN",
        "CANC",
        "ABD",
        "AWD",
        "WO",
    }

    if status_short in live_statuses:
        ttl_seconds = 60
    elif status_short in finished_statuses:
        ttl_seconds = 86400
    else:
        ttl_seconds = 300

    await cache.set(
        key=cache_key,
        value=result,
        ttl_seconds=ttl_seconds,
    )

    return {
        **result,
        "cached": False,
    }