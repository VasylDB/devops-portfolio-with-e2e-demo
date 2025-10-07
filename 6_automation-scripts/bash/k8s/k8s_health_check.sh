#!/usr/bin/env bash
set -euo pipefail
# Check Deployments readiness and pod restarts in a namespace.
# Exits non-zero if problems detected.
# Usage:
#   ./k8s_health_check.sh <namespace> [max-restarts]

NAMESPACE="${1:-default}"
MAX_RESTARTS="${2:-3}"

echo "[INFO] Checking deployments in ns/${NAMESPACE}"
NOT_READY=0

mapfile -t DEPLOYS < <(kubectl -n "$NAMESPACE" get deploy -o name)
for d in "${DEPLOYS[@]}"; do
  READY=$(kubectl -n "$NAMESPACE" get "$d" -o jsonpath='{.status.readyReplicas}')
  DESIRED=$(kubectl -n "$NAMESPACE" get "$d" -o jsonpath='{.status.replicas}')
  READY=${READY:-0}; DESIRED=${DESIRED:-0}
  echo "  - $d: ${READY}/${DESIRED} ready"
  if [[ "$READY" != "$DESIRED" ]]; then
    NOT_READY=1
  fi
done

echo "[INFO] Checking pod restarts <= ${MAX_RESTARTS}"
mapfile -t PODS < <(kubectl -n "$NAMESPACE" get pods -o name)
for p in "${PODS[@]}"; do
  RESTARTS=$(kubectl -n "$NAMESPACE" get "$p" -o jsonpath='{range .status.containerStatuses[*]}{.restartCount}{"\n"}{end}' | awk '{s+=$1} END{print s+0}')
  RESTARTS=${RESTARTS:-0}
  echo "  - $p: restarts=${RESTARTS}"
  if (( RESTARTS > MAX_RESTARTS )); then
    NOT_READY=1
  fi
done

if (( NOT_READY )); then
  echo "[WARN] Health check failed."
  exit 2
fi

echo "[OK] Health check passed."
