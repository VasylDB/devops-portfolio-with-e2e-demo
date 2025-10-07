# Containerization & Orchestration Mini‑Project (Windows 10 Ready)

- API (Express) + Worker (Node.js) + Redis
- Docker Compose for local dev
- Helm chart with Ingress, HPA, ConfigMap & Secret

## Prerequisites (Windows 10)
- Docker Desktop (with `docker compose`)
- PowerShell 5+ or 7
- kubectl & Helm 3 in PATH (e.g. `choco install kubernetes-cli kubernetes-helm`)

## Quick Start (Docker Compose)
```powershell
Copy-Item .env.example .env
Set-ExecutionPolicy -Scope Process Bypass -Force  # allow local scripts in this session
.\scripts\build-images.ps1 -Tag local
docker compose up -d
curl http://localhost:3000/
Invoke-RestMethod http://localhost:3000/enqueue
```

Stop & clean:
```powershell
docker compose down -v
```

## Kubernetes (Helm)
```powershell
$env:REGISTRY = "ghcr.io/<your-user>"
$tag = "latest"
.\scripts\build-images.ps1 -Tag $tag
.\scripts\push-images.ps1 -Registry $env:REGISTRY -Tag $tag

$ns = "demo"
.\scripts\helm-install.ps1 -Namespace $ns
kubectl -n $ns get all
```

### Ingress (local)
```powershell
Start-Process powershell -Verb runAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ".\scripts\setup-hosts.ps1" -Host "demo.local" -Ip "127.0.0.1"'
```
Update `values.yaml` host to `demo.local` and run an ingress controller (e.g., nginx).

## Config & Secrets
```powershell
.\scripts\mk-secure-values.ps1 -OutFile secure-values.yaml
helm upgrade --install stack k8s/helm/stack -n demo `
  -f k8s/helm/stack/values.yaml `
  -f secure-values.yaml
```

## Best Practices
- Minimal images, non‑root, pinned versions
- Separate Config vs Secret; never commit real secrets
- Set requests/limits for effective HPA
- Use Ingress over NodePort for exposure
