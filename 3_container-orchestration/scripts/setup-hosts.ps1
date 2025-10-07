param(
    [string]$Hostname   = "demo.local",
    [string]$IP         = "127.0.0.1"
)

$hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
$winIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($winIdentity)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run elevated.";
    exit 1
}

$content = Get-Content -Path $hostsPath -Raw
$pattern = "(?m)^\s*$([regex]::Escape($IP))\s+$([regex]::Escape($Hostname))\s*$"

if ($content -match $pattern) {
    Write-Host "Mapping exists."
} else {
    Add-Content -Path $hostsPath -Value "`n$Ip`t$Hostname";
    Write-Host "Added mapping."
}
