param(
    [string]$Tag = "local"
)

$ErrorActionPreference = "Stop"

$env:DOCKER_BUILDKIT = "1"
docker build -t "demo/app:$Tag" "docker/app"
docker build -t "demo/worker:$Tag" "docker/worker"
Write-Host "Done."
