#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}/frontend"

: "${FRONTEND_S3_BUCKET:?Set FRONTEND_S3_BUCKET}"
: "${CLOUDFRONT_DISTRIBUTION_ID:?Set CLOUDFRONT_DISTRIBUTION_ID}"

echo "==> npm ci"
npm ci

echo "==> npm audit"
npm audit --audit-level=high || true

echo "==> build"
VITE_API_BASE_URL=/api npm run build

echo "==> sync to S3"
aws s3 sync dist/ "s3://${FRONTEND_S3_BUCKET}/" --delete

echo "==> invalidate CloudFront"
aws cloudfront create-invalidation \
  --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
  --paths "/*"

echo "Frontend deployed."
