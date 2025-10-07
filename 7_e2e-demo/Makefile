# Simple make targets to streamline common tasks. Run `make help`.
.PHONY: help bootstrap tf-init tf-plan tf-apply tf-destroy build docker-push deploy-staging deploy-prod kube-context

AWS_REGION ?= eu-central-1
ENV ?= staging
APP ?= service-api
IMAGE_TAG ?= v0.1.$$(date +%Y%m%d%H%M%S)

help:
	@echo "Available targets:"
	@echo "  bootstrap        - Create Terraform remote state backend (S3 + DynamoDB)"
	@echo "  tf-init/plan/apply/destroy - Manage Terraform in infra/terraform/envs/$(ENV)"
	@echo "  build            - Build Docker image for $(APP)"
	@echo "  docker-push      - Push Docker image to ECR (requires prior 'aws ecr get-login-password')"
	@echo "  deploy-staging   - Helm upgrade --install to staging"
	@echo "  deploy-prod      - Helm upgrade --install to prod"

bootstrap:
	bash infra/bootstrap/create_backend.sh

tf-init:
	cd infra/terraform/envs/$(ENV) && terraform init

tf-plan:
	cd infra/terraform/envs/$(ENV) && terraform plan -var-file=terraform.tfvars

tf-apply:
	cd infra/terraform/envs/$(ENV) && terraform apply -auto-approve -var-file=terraform.tfvars

tf-destroy:
	cd infra/terraform/envs/$(ENV) && terraform destroy -auto-approve -var-file=terraform.tfvars

build:
	cd app/service-api && docker build -t $(APP):$(IMAGE_TAG) .

docker-push:
	bash scripts/docker_push.sh $(APP) $(IMAGE_TAG)

deploy-staging:
	ENV=staging bash deploy/deploy.sh

deploy-prod:
	ENV=prod bash deploy/deploy.sh
