import asyncio
import time
from typing import Any, Optional


class TTLCache:
    def __init__(self) -> None:
        self._items: dict[str, tuple[float, Any]] = {}
        self._lock = asyncio.Lock()

    async def get(self, key: str) -> Optional[Any]:
        async with self._lock:
            item = self._items.get(key)

            if item is None:
                return None

            expires_at, value = item

            if time.monotonic() >= expires_at:
                del self._items[key]
                return None

            return value

    async def set(
        self,
        key: str,
        value: Any,
        ttl_seconds: int,
    ) -> None:
        async with self._lock:
            expires_at = time.monotonic() + ttl_seconds
            self._items[key] = (expires_at, value)


cache = TTLCache()