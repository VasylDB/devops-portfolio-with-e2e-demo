param(
    [string]$OutFile="secure-values.yaml"
)

$bytes = New-Object byte[] 32; (new-object System.Random).NextBytes($bytes)
$token = [Convert]::ToBase64String($bytes)

@"
secret:
    SECRET_TOKEN: "$token"
"@ | Set-Content -Path $OutFile -NoNewline

Write-Host "Wrote $OutFile"
