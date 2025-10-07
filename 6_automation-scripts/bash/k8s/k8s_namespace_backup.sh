#!/usr/bin/env bash
set -euo pipefail
# Export K8s namespace resources as YAML (lightweight backup).
# Usage:
#   ./k8s_namespace_backup.sh <namespace> <output-dir>

NS="${1:-}"
OUT="${2:-}"

if [[ -z "$NS" || -z "$OUT" ]]; then
  echo "Usage: $0 <namespace> <output-dir>"
  exit 1
fi

mkdir -p "$OUT"
echo "[INFO] Exporting resources from ns/${NS} to ${OUT}"

# Common resource kinds — adjust as needed
KINDS=("deployments" "statefulsets" "daemonsets" "services" "ingresses" "configmaps" "secrets" "pvc" "cronjobs" "jobs")

for k in "${KINDS[@]}"; do
  kubectl -n "$NS" get "$k" -o yaml > "${OUT}/${k}.yaml" || true
done

echo "[OK] Namespace export complete."
