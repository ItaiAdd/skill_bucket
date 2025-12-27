from fastapi import FastAPI

app = FastAPI(title="SkillBucket API")

@app.get("/health")
def health():
    return {"status": "I'm fine"}
