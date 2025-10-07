# Jenkins CI/CD Pipeline

This pipeline builds a Docker image from 'app/', pushes it to **AWS ECR**, and deploys to **EKS** using k8s/deployment.yaml.

## Setup
1. Create ECR repo named 'myapp' and note your '<account_id>' and region.
2. Make sure Jenkins agent has: Docker, AWS CLI, kubectl, and EKS context configured.
3. Update placeholders in 'Jenkinsfile' ('<account_id>', region, etc.).
