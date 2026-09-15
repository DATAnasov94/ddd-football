from typing import Any

import httpx

from app.core.config import (
    API_FOOTBALL_BASE_URL,
    API_FOOTBALL_KEY,
)


class FootballAPIError(Exception):
    """Грешка при комуникация с API-Football."""


class FootballAPIClient:
    def __init__(self) -> None:
        self.base_url = API_FOOTBALL_BASE_URL
        self.headers = {
            "x-apisports-key": API_FOOTBALL_KEY,
        }

    async def get_fixtures(
        self,
        date: str,
        timezone: str = "Europe/Sofia",
    ) -> list[dict[str, Any]]:
        params = {
            "date": date,
            "timezone": timezone,
        }

        try:
            async with httpx.AsyncClient(timeout=15) as client:
                response = await client.get(
                    f"{self.base_url}/fixtures",
                    headers=self.headers,
                    params=params,
                )

                response.raise_for_status()

        except httpx.TimeoutException as exc:
            raise FootballAPIError(
                "API-Football не отговори навреме."
            ) from exc

        except httpx.HTTPStatusError as exc:
            raise FootballAPIError(
                f"API-Football върна HTTP {exc.response.status_code}."
            ) from exc

        except httpx.RequestError as exc:
            raise FootballAPIError(
                "Няма връзка с API-Football."
            ) from exc

        payload = response.json()

        if payload.get("errors"):
            raise FootballAPIError(
                f"API-Football грешка: {payload['errors']}"
            )

        return payload.get("response", [])


football_api_client = FootballAPIClient()