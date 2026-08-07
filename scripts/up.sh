#!/usr/bin/env bash
set -euo pipefail

# Allow GUI apps from local Docker containers.
xhost +local:docker >/dev/null 2>&1 || true

docker compose up -d
docker compose exec mentorpi_dev bash
