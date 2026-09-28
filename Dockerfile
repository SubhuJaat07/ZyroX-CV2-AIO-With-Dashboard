# ──────────────────────────────────────────────────────────────────────────────
# Dockerfile for ZyroX-CV2-AIO bot (Railway / any container platform)
# Builds the bot from bot/ subfolder. Dashboard is deployed separately.
# ──────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim

# System dependencies needed by Python packages + runtime
#   build-essential  → gcc for any package that needs source compile
#   libffi-dev       → cffi (used by discord.py indirectly)
#   libssl-dev       → cryptography / ssl
#   ffmpeg           → audio processing (music / voice cogs)
#   espeak-ng        → pyttsx3 (text-to-speech)
#   ncurses-bin      → provides `clear` command (used by os.system("clear"))
#   ca-certificates  → outbound HTTPS
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev \
        ffmpeg \
        espeak-ng \
        ncurses-bin \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/bot

# Install Python dependencies first (better Docker layer caching)
COPY bot/requirements.txt /app/bot/requirements.txt
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r /app/bot/requirements.txt

# Copy the entire bot source
COPY bot/ /app/bot/

# Runtime environment
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    TERM=xterm \
    API_ENABLED=true \
    API_PORT=8000 \
    TUNNEL_ENABLED=false

# Railway auto-detects this port — uvicorn listens on 0.0.0.0:8000
EXPOSE 8000

# Bot entry point
CMD ["python", "CodeX.py"]
