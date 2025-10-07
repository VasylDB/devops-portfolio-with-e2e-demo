# Lightweight Threat Model

## Assets
- Demo API, container image, Terraform IaC.

## Entry Points
- HTTP :3000, GitHub repository (PRs).

## Threats (STRIDE-ish)
- Injection (SAST, DAST)
- Vulnerable deps (Trivy)
- Misconfigured cloud IaC (Checkov)
- Secrets exposure in repo (none in this demo)

## Mitigations
- Automated scans on PR and main
- Failing thresholds on High/Critical
- Minimal allowlists with tracking
- Short artifact retention
