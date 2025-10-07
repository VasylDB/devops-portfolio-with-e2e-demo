#!/usr/bin/env bash
set -euo pipefail
# Start a Session Manager shell to an EC2 instance by Name tag.
# Usage:
#   ./ec2_ssm_connect.sh <instance-name> [region]

NAME="${1:-}"
REGION="${2:-}"

if [[ -z "$NAME" ]]; then
  echo "Usage: $0 <instance-name> [region]"
  exit 1
fi

JQ_FILTER='.Reservations[].Instances[] | select(.Tags[]?.Value=="'${NAME}'") | .InstanceId'
INSTANCE_ID=$(aws ec2 describe-instances ${REGION:+--region $REGION} --filters Name=instance-state-name,Values=running | jq -r "$JQ_FILTER" | head -n1)

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "null" ]]; then
  echo "Instance with Name=${NAME} not found or not running" >&2
  exit 1
fi

aws ssm start-session ${REGION:+--region $REGION} --target "$INSTANCE_ID"
