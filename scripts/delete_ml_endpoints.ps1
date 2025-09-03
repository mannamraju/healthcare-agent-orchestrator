Param(
  [int]$MaxSeconds = 600,
  [int]$IntervalSeconds = 15
)
Write-Host "[delete-ml] Starting ML endpoint delete + poll"
$envName = azd env get-value AZURE_ENV_NAME 2>$null
if (-not $envName) { Write-Host "[delete-ml] No AZURE_ENV_NAME; exit"; exit 0 }
$rg = azd env get-value AZURE_RESOURCE_GROUP 2>$null
if (-not $rg) { Write-Host "[delete-ml] No resource group; exit"; exit 0 }
$stateFile = ".azure/$envName/terraform.tfstate"
if (-not (Test-Path $stateFile)) { Write-Host "[delete-ml] State file missing; exit"; exit 0 }

$state = Get-Content $stateFile -Raw | ConvertFrom-Json
$endpointResources = $state.resources | Where-Object { $_.type -eq 'azapi_resource' -and $_.name -eq 'ml_online_endpoint' }
if (-not $endpointResources) { Write-Host "[delete-ml] No endpoints in state"; exit 0 }

az extension show -n ml *> $null 2>&1; if ($LASTEXITCODE -ne 0) { az extension add -n ml -y *> $null 2>&1 }

$endpointIds = @()
foreach ($res in $endpointResources) { foreach ($inst in $res.instances) { if ($inst.attributes.id) { $endpointIds += $inst.attributes.id } } }

foreach ($rid in $endpointIds) {
  if ($rid -match '/workspaces/([^/]+)/onlineEndpoints/([^/]+)$') { $ws=$Matches[1]; $ep=$Matches[2] } else { continue }
  Write-Host "[delete-ml] Deleting endpoint $ep (workspace=$ws)"
  az ml online-endpoint delete -g $rg -w $ws -n $ep --yes --no-wait *> $null 2>&1
  az rest -m DELETE -u "https://management.azure.com$rid?api-version=2024-10-01" *> $null 2>&1
}

$elapsed = 0
while ($elapsed -lt $MaxSeconds) {
  $remaining = 0
  foreach ($rid in $endpointIds) {
    if ($rid -match '/workspaces/([^/]+)/onlineEndpoints/([^/]+)$') { $ws=$Matches[1]; $ep=$Matches[2] } else { continue }
    az ml online-endpoint show -g $rg -w $ws -n $ep *> $null 2>&1
    if ($LASTEXITCODE -eq 0) { $remaining++ }
  }
  if ($remaining -eq 0) { Write-Host "[delete-ml] All endpoints gone after $elapsed s"; break }
  Write-Host "[delete-ml] $remaining endpoints still present after $elapsed s; waiting..."; Start-Sleep -Seconds $IntervalSeconds; $elapsed += $IntervalSeconds
}
if ($elapsed -ge $MaxSeconds) { Write-Host "[delete-ml] WARNING: Some endpoints still reported after $MaxSeconds s; continuing" }
