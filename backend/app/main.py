from fastapi import FastAPI

from app.api.routes.matches import router as matches_router


app = FastAPI(
    title="дДд Football API",
    description="Backend API за футболни мачове, резултати и прогнози.",
    version="0.1.0",
)

app.include_router(matches_router)


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