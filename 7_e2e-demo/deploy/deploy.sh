#!/usr/bin/env bash
set -euo pipefail

ENV=${ENV:-staging}
NAMESPACE=apps
RELEASE=service-api

# Image tag is passed via env in CI or defaults to local latest
: "${IMAGE_TAG:=latest}"
: "${AWS_ACCOUNT_ID:=000000000000}"
: "${AWS_REGION:=eu-central-1}"

IMAGE_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/service-api"

kubectl get ns $NAMESPACE >/dev/null 2>&1 || kubectl create ns $NAMESPACE

helm upgrade --install $RELEASE app/service-api/k8s/helm/service-api \
  -n $NAMESPACE \
  --set image.repository="$IMAGE_REPO" \
  --set image.tag="$IMAGE_TAG"
