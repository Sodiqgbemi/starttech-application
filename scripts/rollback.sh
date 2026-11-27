#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-eu-north-1}"
EKS_CLUSTER="${EKS_CLUSTER:-starttech-cluster}"
REVISION="${1:-}"

aws eks update-kubeconfig --name "${EKS_CLUSTER}" --region "${AWS_REGION}"

if [[ -n "${REVISION}" ]]; then
  echo "==> rolling back backend-api to revision ${REVISION}"
  kubectl rollout undo deployment/backend-api --to-revision="${REVISION}"
else
  echo "==> rolling back backend-api to previous revision"
  kubectl rollout undo deployment/backend-api
fi

kubectl rollout status deployment/backend-api --timeout=180s
echo "Rollback complete."
