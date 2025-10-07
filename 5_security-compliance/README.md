# Portfolio – Part 5: Security & Compliance

This mini‑project **Security & Compliance** with:
- **Container scanning** using [Trivy]
- **IaC scanning** using [Checkov]
- **SAST** using **CodeQL** (JavaScript/TypeScript) and **Semgrep** (optional)
- **DAST** using **OWASP ZAP** baseline scan
- CI via **GitHub Actions** with SARIF uploads to **GitHub Security** tab

> Target app is a tiny Express.js API (Dockerized) to make scans reproducible on any machine.

---

## What’s inside

```
portfolio-5-security-compliance/
├─ .github/workflows/
│  ├─ security-trivy-fs.yml          # Trivy filesystem scan (SCA + Vulns/Misconfig)
│  ├─ security-trivy-image.yml       # Trivy image scan after Docker build
│  ├─ security-checkov.yml           # Checkov Terraform scan (IaC)
│  ├─ security-codeql-js.yml         # CodeQL SAST for JS/TS
│  ├─ security-semgrep.yml           # OPTIONAL: Semgrep SAST
│  └─ security-zap-dast.yml          # OWASP ZAP baseline DAST against the running app
├─ trivy/
│  ├─ trivy.yaml                     # Trivy config
│  └─ .trivyignore                   # Allowlist CVEs/paths (keep short)
├─ checkov/
│  ├─ config.yml                     # Checkov config
│  └─ suppressions.yaml              # Optional suppressions with justifications
├─ sast/
│  └─ .semgrep.yaml                  # Optional Semgrep rules (safe defaults)
├─ dast/
│  └─ zap-baseline.conf              # URLs and allowlist for ZAP
├─ iac/terraform/
│  ├─ main.tf                        # Sample AWS resources (intentionally mixed quality)
│  ├─ variables.tf
│  ├─ outputs.tf
│  └─ README.md
├─ src/app/
│  ├─ index.js                       # Express demo app
│  ├─ package.json
│  └─ package-lock.json              # minimal lock for reproducibility
├─ Dockerfile
├─ docker-compose.yml
├─ SECURITY.md                       # Reporting policy
├─ scripts/                          # Local helper scripts (Windows-friendly)
│  ├─ run_trivy_fs.ps1
│  ├─ run_trivy_image.ps1
│  └─ run_checkov.ps1
└─ docs/
   ├─ architecture.md                # High-level view
   └─ threat-model.md                # Lightweight threat model
```

### CI overview (quick)

- **On PRs:** run CodeQL, Trivy FS, and Checkov. Fail build on High/Critical. Upload SARIF.
- **On pushes to `main`:** build Docker image, run Trivy image scan, and ZAP baseline against the container.
- **Artifacts:** HTML reports and SARIF kept for **7 days**.

> Thresholds are conservative to avoid noise: warn on Medium; **fail** on High/Critical. Tune via config files.

---

## Local usage (Windows 10 friendly)

1) **Prereqs**: Docker Desktop, Node.js 18+, Python 3 (optional), PowerShell 5+.
2) **Run the app:**  
```powershell
cd src/app
npm ci
npm start
# App on http://127.0.0.1:3000/health
```
or via Docker:
```powershell
docker compose up --build
```
3) **Trivy FS scan:**  
```powershell
./scripts/run_trivy_fs.ps1
```
4) **Trivy image scan:**  
```powershell
./scripts/run_trivy_image.ps1
```
5) **Checkov scan:**  
```powershell
./scripts/run_checkov.ps1
```

---

## GitHub Actions setup

- In **Settings → Code security and analysis**, enable **CodeQL** and **Dependency Graph**.
- For ZAP DAST against PR deployments, change the target URL in `security-zap-dast.yml` (by default it builds & runs locally in CI).

> No cloud creds needed for this demo. If you later scan real cloud IaC, add AWS creds via OIDC + role assumption (recommended) or temporary keys.

---

## Notes & policy

- Keep `.trivyignore` and `checkov/suppressions.yaml` minimal with **references to tickets** and a **review date**.
- All workflows produce **SARIF** and/or **HTML** outputs; see **Actions → Run → Artifacts** and the repository **Security** tab.
- This project is designed for **intermediate** engineers and includes comments inline.

Good luck!

[Trivy]: https://github.com/aquasecurity/trivy
[Checkov]: https://www.checkov.io/
[CodeQL]: https://codeql.github.com/
[Semgrep]: https://semgrep.dev/
[ZAP]: https://www.zaproxy.org/
