#!/usr/bin/env bash
set -euo pipefail

: "${AWS_REGION:=eu-central-1}"
: "${TF_BACKEND_BUCKET:=e2e-demo-tfstate}"
: "${TF_BACKEND_TABLE:=e2e-demo-tflock}"

aws s3api create-bucket --bucket "$TF_BACKEND_BUCKET" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION" >/dev/null 2>&1 || true
aws s3api put-bucket-versioning --bucket "$TF_BACKEND_BUCKET" --versioning-configuration Status=Enabled >/dev/null
aws dynamodb create-table --table-name "$TF_BACKEND_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --region "$AWS_REGION" >/dev/null 2>&1 || true

echo "Backend ready: s3://${TF_BACKEND_BUCKET}, table ${TF_BACKEND_TABLE}"
