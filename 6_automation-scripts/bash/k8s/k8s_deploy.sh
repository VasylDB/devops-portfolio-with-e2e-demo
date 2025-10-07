#!/usr/bin/env bash
set -euo pipefail
# Deploy a kustomize dir or yaml manifest to a specific namespace.
# Usage:
#   ./k8s_deploy.sh <path-to-yaml-or-dir> <namespace>

PATH_ARG="${1:-}"
NAMESPACE="${2:-default}"

if [[ -z "$PATH_ARG" ]]; then
  echo "Usage: $0 <yaml-or-dir> <namespace>"
  exit 1
fi

kubectl get ns "$NAMESPACE" >/dev/null 2>&1 || kubectl create ns "$NAMESPACE"

if [[ -d "$PATH_ARG" ]]; then
  echo "[INFO] Applying kustomize dir: $PATH_ARG to ns/$NAMESPACE"
  kubectl -n "$NAMESPACE" apply -k "$PATH_ARG"
else
  echo "[INFO] Applying file: $PATH_ARG to ns/$NAMESPACE"
  kubectl -n "$NAMESPACE" apply -f "$PATH_ARG"
fi

echo "[OK] Deploy applied."
