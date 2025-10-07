# Automation Scripts — Mini Project (Portfolio Item 6)

This mini-project contains **Bash & Python tools for AWS and Kubernetes** covering **backups, deployment, and health checks**.

> Notes:
> - All code comments are in English (per your standard).
> - Scripts are intentionally straightforward, written at an intermediate level.
> - Commands should be run **one at a time** and observed (your preference).

## Contents

- `bash/aws/`
  - `s3_backup.sh` — sync a local folder to S3 with encryption and tagging
  - `ecr_login_push.sh` — ECR login + Docker push helper
  - `ec2_ssm_connect.sh` — start a Session Manager shell to an EC2 instance (no PEM keys)
- `bash/k8s/`
  - `k8s_deploy.sh` — apply a kustomize dir or yaml manifest to a selected namespace
  - `k8s_health_check.sh` — check Deployments readiness and pod restarts
  - `k8s_namespace_backup.sh` — export namespace resources as YAML (lightweight backup)
- `python/aws/`
  - `snapshot_ebs.py` — create snapshots for EBS volumes with a specific tag
  - `s3_sync.py` — sync local→S3 using boto3 (small/medium sets; for large, prefer `aws s3 sync`)
  - `iam_keys_audit.py` — report access keys older than N days or unused recently
- `python/k8s/`
  - `cluster_health.py` — nodes/pods health summary with non‑zero exit on issues
  - `rollout_watcher.py` — watch Deployment rollout and notify on success/failure
- `python/common/`
  - `notify.py` — Slack webhook notifier (optional)
- `config/`
  - `backup_config.yml` — example vars for backups
- `.github/workflows/lint.yml` — flake8 for Python, shellcheck for Bash
- `Makefile` — handy targets
- `requirements.txt` — Python deps
- `.env.example` — environment variables template

---

## Quick start

1) **Python env**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   ```

2) **AWS auth**
   - Prefer OIDC on CI. Locally use `aws configure sso` (no static keys) or session env vars.

3) **Kube access**
   - Make sure `kubectl` context points to your cluster (`kubectl config get-contexts`).

4) **Try a health check**
   ```bash
   python python/k8s/cluster_health.py --namespace default
   ```

5) **Backup namespace manifests (lightweight)**
   ```bash
   bash/bash/k8s/k8s_namespace_backup.sh default ./backups/default-$(date +%F)
   ```

---

## Configuration

- `config/backup_config.yml` includes examples for S3 bucket and tags.
- For Slack notifications set `SLACK_WEBHOOK_URL` in `.env` or environment.

---

## Safety & Limits

- **Backups** here are sample patterns. For production-grade cluster backups, consider tools like Velero.
- EBS snapshots can incur costs. Tag them and set lifecycle policies.
- Use `--dry-run` modes when available and review actions.

