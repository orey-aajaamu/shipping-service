#!/usr/bin/env bash
set -euo pipefail

# --- inputs (exported by the caller) ---
: "${IMAGE:?IMAGE is required}"
: "${APP_ENVIRONMENT:?APP_ENVIRONMENT is required}"
HOST_PORT="${HOST_PORT:-8000}"
CONTAINER_NAME="${CONTAINER_NAME:-shipping-${APP_ENVIRONMENT}}"

echo "==> Deploying ${IMAGE} as ${CONTAINER_NAME} on port ${HOST_PORT}"

echo "==> Pulling image"
docker pull "${IMAGE}"

PREVIOUS=$(docker inspect --format='{{.Config.Image}}' "${CONTAINER_NAME}" 2>/dev/null || echo "none")
echo "==> Previous image: ${PREVIOUS}"

echo "==> Stopping old container (if any)"
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "==> Starting new container"
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "${HOST_PORT}:8000" \
  -e APP_ENVIRONMENT="${APP_ENVIRONMENT}" \
  "${IMAGE}"

echo "==> Waiting for health"
for i in $(seq 1 30); do
  if curl -fsS "http://localhost:${HOST_PORT}/health" > /dev/null 2>&1; then
    echo "==> Healthy after ${i}s"
    curl -sS "http://localhost:${HOST_PORT}/health"
    echo
    echo "${PREVIOUS}" > "/home/ec2-user/.previous-${CONTAINER_NAME}"
    exit 0
  fi
  sleep 1
done

echo "ERROR: container did not become healthy in 30s"
docker logs --tail 50 "${CONTAINER_NAME}" || true
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

if [ "${PREVIOUS}" != "none" ]; then
  echo "==> Rolling back to ${PREVIOUS}"
  docker run -d --name "${CONTAINER_NAME}" --restart unless-stopped \
    -p "${HOST_PORT}:8000" -e APP_ENVIRONMENT="${APP_ENVIRONMENT}" "${PREVIOUS}"
fi
exit 1