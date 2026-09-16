from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes.matches import router as matches_router
from app.api.routes.leagues import router as leagues_router


app = FastAPI(
    title="дДд Football API",
    description="Backend API за футболни мачове, резултати и прогнози.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(matches_router)
app.include_router(leagues_router)


@app.get("/", tags=["System"])
async def root():
    return {
        "application": "дДд Football",
        "status": "running",
        "version": "0.1.0",
    }


@app.get("/api/health", tags=["System"])
async def health_check():
    return {
        "status": "healthy",
    }