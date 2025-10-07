#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT=${1:?staging|prod}
: "${AWS_REGION:=eu-central-1}"

CLUSTER_NAME="e2e-${ENVIRONMENT}-eks"
echo "Updating kubeconfig for cluster: ${CLUSTER_NAME}"
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
kubectl config set-context --current --namespace=apps
