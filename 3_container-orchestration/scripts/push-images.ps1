param(
    [Parameter(Mandatory=$true)][string]$Registry,
    [string]$Tag="latest",
    [string]$AppRepo = "demo-app",
    [string]$WorkerRepo = "demo-worker"
)

$ErrorActionPreference="Stop"

$Registry = $Registry.TrimEnd('/')

function Assert-ImageExists([string]$Ref) {
    if (-not (docker image ls -q $Ref)) {
        throw "Local image not found: $Ref. Build it first."
    }    
}

$srcApp = "demo/app:$Tag"
$srcWorker  = "demo/worker:$Tag"
$dstApp = "$Registry/demo-app:$Tag"
$dstWorker  = "$Registry/demo-worker:$Tag"

Write-Host "Tagging"
Write-Host " $srcApp     -> $dstApp"
Write-Host " $srcWorker  -> $dstWorker"

Assert-ImageExists $srcApp
Assert-ImageExists $srcWorker

docker tag $srcApp $dstApp
docker tag $srcWorker $dstWorker

Write-Host "Pushing"
docker push $dstApp
docker push $dstWorker

Write-Host "Done."
