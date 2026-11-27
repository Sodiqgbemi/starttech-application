#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-}"
if [[ -z "${BASE_URL}" ]]; then
  echo "Usage: $0 <cloudfront-or-api-base-url>"
  echo "Example: $0 https://d1234.cloudfront.net"
  exit 1
fi

echo "==> GET ${BASE_URL}/api/v1/health"
curl -sf "${BASE_URL}/api/v1/health" | tee /tmp/starttech-health.json
echo
echo "Health check OK"
