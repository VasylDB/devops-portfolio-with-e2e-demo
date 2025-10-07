# CI/CD Pipelines - Mini Project

This mini project demonstrates three CI/CD setups:
- **Jenkins pipeline**

A tiny sample app (Node.js) and Kubernetes manifests are included to let you build, push, and deploy quickly.

## Quick start (local build)

cd app
docker build -t myapp:latest .
docker run -p 8080:8080 myapp:latest
# open http://localhost:8080


## Kubernetes deploy (manually)
Update the image in 'k8s/deployment.yaml' to the registry/tag you push in your CI.

kubectl apply -f k8s/
kubectl get pods,svc -n default

> Replace placeholders like '<account_id>', registry URLs, cluster names, and resource groups according to your environment.