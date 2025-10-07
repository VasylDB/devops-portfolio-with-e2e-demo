# Runbook (one command at a time)

> Assumes: AWS CLI v2, kubectl, Helm, Terraform, and Docker installed. Region variables are pre-set.

## 1) Backend for Terraform state
1. `make bootstrap`

## 2) Provision staging
1. `make tf-init ENV=staging`
2. `make tf-apply ENV=staging`

## 3) Kubeconfig
1. `bash scripts/kubeconfig.sh staging`

## 4) Monitoring
1. `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`
2. `helm repo update`
3. `helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f monitoring/helm/kube-prometheus-stack/values.yaml`

## 5) Build/Push image
1. `make build`
2. `make docker-push`

## 6) Deploy app
1. `make deploy-staging`

## 7) Verify
1. `kubectl get pods -n apps`
2. `kubectl get svc -n apps`
3. `kubectl get hpa -n apps`
4. Port-forward to Grafana: `kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80`
