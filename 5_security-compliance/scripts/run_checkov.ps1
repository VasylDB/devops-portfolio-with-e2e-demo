if (-not (Get-Command checkov -ErrorAction SilentlyContinue)) {
  Write-Error "Checkov not found. Install with: pip install checkov"
  exit 1
}
New-Item -ItemType Directory -Force -Path checkov-results | Out-Null
checkov -c checkov/config.yml --skip-suppressions none --compact
Write-Host "Checkov results in checkov-results/"
