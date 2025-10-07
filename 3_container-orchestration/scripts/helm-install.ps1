param(
    [string]$Release="stack",
    [string]$Namespace="demo",
    [string]$Values="k8s/helm/stack/values.yaml"
)

$ErrorActionPreference="Stop"

kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install $Release "k8s/helm/stack" -n $Namespace -f $Values
