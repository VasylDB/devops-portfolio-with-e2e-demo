# Architecture (Security View)

- A tiny Express.js service packaged into a Docker image.
- CI builds the image, runs scanners:
  - Trivy filesystem (SCA + vuln)
  - Trivy image (OS + libs)
  - Checkov for Terraform
  - CodeQL / Semgrep (SAST)
  - ZAP baseline (DAST) against the running container
- SARIF uploads to GitHub Security. HTML artifacts kept 7 days.
