#!/usr/bin/env bash
set -euo pipefail
# Helper: login to ECR and push an image
# Usage:
#   ./ecr_login_push.sh <aws-region> <account-id> <repo-name> <local-image:tag> <tag>

REGION="${1:-}"
ACCOUNT_ID="${2:-}"
REPO="${3:-}"
LOCAL_IMAGE="${4:-}"
TAG="${5:-latest}"

if [[ -z "$REGION" || -z "$ACCOUNT_ID" || -z "$REPO" || -z "$LOCAL_IMAGE" ]]; then
  echo "Usage: $0 <region> <account-id> <repo> <local-image:tag> <tag>"
  exit 1
fi

aws ecr get-login-password --region "$REGION" |       docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

REMOTE="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}"
docker tag "${LOCAL_IMAGE}" "${REMOTE}"
docker push "${REMOTE}"
echo "[OK] Pushed ${REMOTE}"
