#!/usr/bin/env bash
set -euo pipefail

IMAGE=${1:?image ref}
trivy image --severity HIGH,CRITICAL --exit-code 0 --format table "$IMAGE"
