#!/usr/bin/env bash
set -euo pipefail
# Simple S3 backup using aws-cli sync
# Usage:
#   ./s3_backup.sh /path/to/src s3://my-bucket/prefix [--delete]
# Requirements: aws cli configured; bucket exists. Uses SSE by default.

SRC_DIR="${1:-}"
S3_URI="${2:-}"
DELETE_FLAG="${3:-}"

if [[ -z "$SRC_DIR" || -z "$S3_URI" ]]; then
  echo "Usage: $0 <SRC_DIR> <S3_URI> [--delete]"
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Source dir not found: $SRC_DIR" >&2
  exit 1
fi

EXTRA_OPTS=(--sse AES256 --only-show-errors)
if [[ "$DELETE_FLAG" == "--delete" ]]; then
  EXTRA_OPTS+=("--delete")
fi

echo "[INFO] Syncing $SRC_DIR -> $S3_URI"
aws s3 sync "$SRC_DIR" "$S3_URI" "${EXTRA_OPTS[@]}"

# Optional tagging at prefix root (best-effort; object-level tagging is separate)
# You can use S3 Object Tagging in advanced workflows.

echo "[OK] Backup finished."
