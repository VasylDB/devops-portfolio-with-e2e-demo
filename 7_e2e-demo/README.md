# End-to-End DevOps Demo (IaC + CI/CD + K8s + Monitoring)

> Purpose: Minimal yet realistic demo showing **Terraform (AWS EKS)**, **GitHub Actions CI/CD** with **OIDC**,
**Helm** deploys to Kubernetes, and **Monitoring** via kube-prometheus-stack (Prometheus + Grafana).

## What you get
- Terraform modules for VPC, EKS, ECR, and IAM roles.
- Two environments: **staging** and **prod**.
- Sample Node.js service (`app/service-api`) + Helm chart with HPA/Ingress/ServiceMonitor.
- GitHub Actions: `ci.yml` (build/test/scan), `cd-staging.yml` (auto on push), `cd-prod.yml` (manual).
- Monitoring stack via `monitoring/helm/kube-prometheus-stack/values.yaml`.
- Security basics: Trivy scan, Checkov config.
- Windows-friendly scripts and CRLF-safe logging.

## Quick start (high level)
1. Create AWS resources for remote state: `make bootstrap`.
2. Provision EKS in **staging**: `make tf-init && make tf-apply ENV=staging`.
3. Authenticate kubectl: `scripts/kubeconfig.sh staging`.
4. Install monitoring: `helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring -f monitoring/helm/kube-prometheus-stack/values.yaml --create-namespace`.
5. Build & push image: `make build && make docker-push`.
6. Deploy app: `make deploy-staging`.
7. Open Grafana (port-forward or Ingress depending on your setup).

> Detailed step-by-step with one-command-at-a-time flow is in `docs/runbook.md`.
