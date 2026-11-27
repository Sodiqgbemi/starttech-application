# starttech-application

React frontend + Golang backend for the StartTech DevOps assessment, with Kubernetes manifests and GitHub Actions CI/CD.

## Layout

```
frontend/     React (Vite) SPA — API calls use relative /api
backend/      Golang REST API (port 8080)
k8s/          Deployment, Service, Ingress (ALB)
scripts/      deploy / health-check / rollback helpers
```

## Required GitHub secrets

| Secret | Purpose |
|--------|---------|
| `AWS_ACCESS_KEY_ID` | Deploy credentials |
| `AWS_SECRET_ACCESS_KEY` | Deploy credentials |
| `AWS_REGION` | e.g. `us-east-1` |
| `FRONTEND_S3_BUCKET` | From infra `frontend_bucket_name` |
| `CLOUDFRONT_DISTRIBUTION_ID` | From infra `cloudfront_distribution_id` |

## Kubernetes secrets

```bash
cp k8s/secret.yaml.example k8s/secret.yaml
# edit MONGO_URI + JWT_SECRET_KEY
kubectl apply -f k8s/secret.yaml
```

Update `k8s/configmap.yaml` with Redis host from Terraform output `redis_host`.
