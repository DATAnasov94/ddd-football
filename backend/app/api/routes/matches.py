from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

from fastapi import APIRouter, HTTPException, Query

from app.core.cache import cache
from app.services.football_api import (
    FootballAPIError,
    football_api_client,
)


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
):
    return await load_matches(match_date)


@router.get("/today")
async def get_today_matches():
    today = datetime.now(SOFIA_TIMEZONE).date()
    return await load_matches(today)