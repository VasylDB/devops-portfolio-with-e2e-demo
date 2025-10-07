# Troubleshooting

- OIDC auth fails: verify GitHub Actions IAM role trust policy and repo/branch conditions.
- EKS auth issues: ensure your IAM user/role is mapped via aws-auth configmap or use `aws eks update-kubeconfig` with a role that has `eks:DescribeCluster`.
- Pod crashloop: `kubectl logs -n apps deploy/service-api` and check image/ENV vars.
- HPA not scaling: ensure metrics-server is running (kube-prometheus-stack installs it) and CPU requests are set.
