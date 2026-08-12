#!/usr/bin/env bash
set -euo pipefail

echo "==> Verifying clean working tree"
if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: working tree is dirty. Commit or stash before building a release."
  git status --short
  exit 1
fi

VERSION=$(git describe --tags --always --dirty)
COMMIT=$(git rev-parse HEAD)
echo "==> Building $VERSION ($COMMIT)"

rm -rf dist build src/*.egg-info

export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
echo "==> SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH"

python -m build --wheel --sdist

echo "==> Generating checksums"
( cd dist && sha256sum * > SHA256SUMS )
cat dist/SHA256SUMS

cat > dist/build-info.json <<JSON
{
  "version": "$VERSION",
  "commit": "$COMMIT",
  "built_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source_date_epoch": "$SOURCE_DATE_EPOCH"
}
JSON
echo "==> Done"
ls -1 dist/