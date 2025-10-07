param(
  [string]$Target = "."
)
if (-not (Get-Command trivy -ErrorAction SilentlyContinue)) {
  Write-Error "Trivy not found. Install from https://aquasecurity.github.io/trivy/"
  exit 1
}
New-Item -ItemType Directory -Force -Path trivy-results | Out-Null
trivy fs --config trivy/trivy.yaml --format sarif --output trivy-results/trivy-fs.sarif $Target
trivy fs --config trivy/trivy.yaml --output trivy-results/trivy-fs.txt $Target
Write-Host "Trivy FS results in trivy-results/"
