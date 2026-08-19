#!/usr/bin/env bash
set -euo pipefail

APP_ENVIRONMENT="${APP_ENVIRONMENT:?APP_ENVIRONMENT is required}"
HOST_PORT="${HOST_PORT:-8000}"
CONTAINER_NAME="shipping-${APP_ENVIRONMENT}"
STATE_FILE="/home/${USER}/.previous-${CONTAINER_NAME}"

if [ ! -f "$STATE_FILE" ]; then
  echo "ERROR: no previous image recorded at $STATE_FILE"
  exit 1
fi

PREVIOUS=$(cat "$STATE_FILE")
if [ "$PREVIOUS" = "none" ]; then
  echo "ERROR: previous image is 'none' - nothing to roll back to"
  exit 1
fi

CURRENT=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME" 2>/dev/null || echo "none")
echo "==> Rolling back ${CONTAINER_NAME}: ${CURRENT} -> ${PREVIOUS}"

IMAGE="$PREVIOUS" APP_ENVIRONMENT="$APP_ENVIRONMENT" HOST_PORT="$HOST_PORT" bash "$(dirname "$0")/deploy.sh"