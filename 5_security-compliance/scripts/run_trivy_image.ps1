param(
  [string]$ImageName = "portfolio-sec-demo:local"
)
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "Docker not found."
  exit 1
}
if (-not (Get-Command trivy -ErrorAction SilentlyContinue)) {
  Write-Error "Trivy not found. Install from https://aquasecurity.github.io/trivy/"
  exit 1
}
docker build -t $ImageName .
New-Item -ItemType Directory -Force -Path trivy-results | Out-Null
trivy image --config trivy/trivy.yaml --format sarif --output trivy-results/trivy-image.sarif $ImageName
trivy image --config trivy/trivy.yaml --output trivy-results/trivy-image.txt $ImageName
Write-Host "Trivy image results in trivy-results/"
