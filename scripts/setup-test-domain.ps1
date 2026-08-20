#Requires -RunAsAdministrator
param(
  [string]$Domain = 'albakor.test',
  [int]$Port = 5001
)

$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$marker = "# albakor-site test domain"
$entry = "127.0.0.1 $Domain"

$hosts = Get-Content $hostsPath -ErrorAction Stop
$filtered = $hosts | Where-Object { $_ -notmatch [regex]::Escape($Domain) -and $_ -ne $marker }
$filtered += $marker
$filtered += $entry
Set-Content -Path $hostsPath -Value $filtered -Encoding ascii

$ruleName = "Albakor Site ($Port)"
$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if (-not $existing) {
  New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow | Out-Null
}

Write-Host "Готово."
Write-Host "Локально:  http://${Domain}:${Port}"
Write-Host "В сети:    http://<ваш-ip>:${Port} или http://<ip-через-дефис>.nip.io:${Port}"
