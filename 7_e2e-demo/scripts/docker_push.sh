#!/usr/bin/env bash
set -euo pipefail

APP=${1:?app name}
TAG=${2:?image tag}
: "${AWS_REGION:=eu-central-1}"
: "${AWS_ACCOUNT_ID:=000000000000}"

REPO_NAME="$APP"
IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${TAG}"

echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Ensuring repository exists: $REPO_NAME"
aws ecr describe-repositories --repository-names "$REPO_NAME" --region "$AWS_REGION" >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name "$REPO_NAME" --image-scanning-configuration scanOnPush=true --region "$AWS_REGION" >/dev/null

echo "Tagging image..."
docker tag "${APP}:${TAG}" "${IMAGE_URI}"

echo "Pushing image..."
docker push "${IMAGE_URI}"

echo "Done. Pushed ${IMAGE_URI}"
