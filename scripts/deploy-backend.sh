#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AWS_REGION="${AWS_REGION:-us-east-1}"
ECR_REPOSITORY="${ECR_REPOSITORY:-starttech-backend-api}"
EKS_CLUSTER="${EKS_CLUSTER:-starttech-cluster}"
IMAGE_TAG="${IMAGE_TAG:-$(git -C "${ROOT_DIR}" rev-parse --short HEAD)}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "==> go test"
(cd "${ROOT_DIR}/backend/api" && go test ./...)

echo "==> ecr login"
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "==> docker build ${IMAGE_URI}"
docker build -t "${IMAGE_URI}" "${ROOT_DIR}/backend"

echo "==> docker push"
docker push "${IMAGE_URI}"

echo "==> update manifest"
sed -i.bak "s|image:.*|image: ${IMAGE_URI}|" "${ROOT_DIR}/k8s/deployment.yaml"

echo "==> kubeconfig"
aws eks update-kubeconfig --name "${EKS_CLUSTER}" --region "${AWS_REGION}"

echo "==> kubectl apply"
kubectl apply -f "${ROOT_DIR}/k8s/"

echo "==> rollout status"
kubectl rollout status deployment/backend-api --timeout=180s

echo "Backend deployed: ${IMAGE_URI}"
