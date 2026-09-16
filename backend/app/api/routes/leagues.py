from datetime import datetime
from typing import Optional
from zoneinfo import ZoneInfo

from fastapi import APIRouter, HTTPException, Path, Query

from app.core.cache import cache
from app.core.leagues import FEATURED_LEAGUES
from app.services.football_api import (
    FootballAPIError,
    football_api_client,
)


router = APIRouter(
    prefix="/api/leagues",
    tags=["Leagues"],
)

SOFIA_TIMEZONE = ZoneInfo("Europe/Sofia")


def format_standing_row(row: dict) -> dict:
    team = row.get("team", {})

    return {
        "rank": row.get("rank"),
        "team": {
            "id": team.get("id"),
            "name": team.get("name"),
            "logo": team.get("logo"),
        },
        "points": row.get("points"),
        "goals_difference": row.get("goalsDiff"),
        "group": row.get("group"),
        "form": row.get("form"),
        "status": row.get("status"),
        "description": row.get("description"),
        "all": row.get("all"),
        "home": row.get("home"),
        "away": row.get("away"),
        "updated_at": row.get("update"),
    }


def format_standings(payload: list) -> dict:
    competition = payload[0].get("league", {})
    groups = []

    for group in competition.get("standings", []):
        groups.append(
            {
                "name": (
                    group[0].get("group")
                    if group
                    else None
                ),
                "table": [
                    format_standing_row(row)
                    for row in group
                ],
            }
        )

    return {
        "league": {
            "id": competition.get("id"),
            "name": competition.get("name"),
            "country": competition.get("country"),
            "logo": competition.get("logo"),
            "flag": competition.get("flag"),
            "season": competition.get("season"),
        },
        "groups": groups,
    }


@router.get("/featured")
async def get_featured_leagues():
    leagues = [
        {
            "id": league_id,
            **league,
        }
        for league_id, league in FEATURED_LEAGUES.items()
    ]

    leagues.sort(key=lambda league: league["priority"])

    return {
        "total": len(leagues),
        "leagues": leagues,
    }


@router.get("/{league_id}/standings")
async def get_league_standings(
    league_id: int = Path(
        ...,
        ge=1,
        description="API-Football league ID",
        examples=[39],
    ),
    season: Optional[int] = Query(
        None,
        ge=2000,
        le=2100,
        description="Началната година на сезона",
        examples=[2026],
    ),
):
    selected_season = season or datetime.now(
        SOFIA_TIMEZONE
    ).year

    cache_key = (
        f"league:standings:{league_id}:{selected_season}"
    )

    cached_result = await cache.get(cache_key)

    if cached_result is not None:
        return {
            **cached_result,
            "cached": True,
        }

    try:
        standings_payload = await football_api_client.get_standings(
            league_id=league_id,
            season=selected_season,
        )
    except FootballAPIError as exc:
        raise HTTPException(
            status_code=502,
            detail=str(exc),
        ) from exc

    if not standings_payload:
        raise HTTPException(
            status_code=404,
            detail={
                "message": "Не е намерено класиране.",
                "league_id": league_id,
                "season": selected_season,
            },
        )

    result = format_standings(standings_payload)

    await cache.set(
        key=cache_key,
        value=result,
        ttl_seconds=3600,
    )

    return {
        **result,
        "cached": False,
    }