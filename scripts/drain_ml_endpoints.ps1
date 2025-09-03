#!/usr/bin/env pwsh
<#! DO NOT REMOVE: shebang above allows execution in POSIX environments with pwsh installed. #>
<#
.SYNOPSIS
PowerShell equivalent of drain_ml_endpoints.sh to clear traffic (route weights) from Azure ML managed online endpoints referenced in Terraform state.

.DESCRIPTION
Reads Terraform state, finds azapi_resource entries for ml_online_endpoint, and clears their traffic maps to avoid destroy failures due to non-zero routing.
#>

Param(
  [switch]$VerboseOutput
)

$ErrorActionPreference = 'Stop'
function Log { param($m) Write-Host "[drain-ml] $m" }

$API_VERSION = "2024-10-01"
$rg       = azd env get-value AZURE_RESOURCE_GROUP 2>$null
$envName  = azd env get-value AZURE_ENV_NAME 2>$null
if (-not $rg)      { Log "No resource group; exiting"; exit 0 }
if (-not $envName) { Log "No AZURE_ENV_NAME; exiting"; exit 0 }
$stateFile = ".azure/$envName/terraform.tfstate"
if (-not (Test-Path $stateFile)) { Log "State file not found ($stateFile); exiting"; exit 0 }

# Parse terraform state JSON
try { $state = Get-Content $stateFile -Raw | ConvertFrom-Json } catch { Log "Failed to parse state JSON"; exit 0 }
$endpointResources = $state.resources | Where-Object { $_.type -eq 'azapi_resource' -and $_.name -eq 'ml_online_endpoint' }
if (-not $endpointResources) { Log "No ML online endpoints in state"; exit 0 }

# Ensure ml extension installed (ignore failure)
az extension show -n ml *> $null 2>&1; if ($LASTEXITCODE -ne 0) { az extension add -n ml -y *> $null 2>&1 }

$drainedAny = $false

foreach ($res in $endpointResources) {
  foreach ($inst in $res.instances) {
    $rid = $inst.attributes.id
    if (-not $rid) { continue }
    # Show raw details first (like bash script echo of GET)
    $details = az rest --method GET --url "https://management.azure.com$rid?api-version=$API_VERSION" 2>$null
    if ($details) { Write-Output $details }

    if ($rid -match '/workspaces/([^/]+)/onlineEndpoints/([^/]+)$') {
      $ws = $Matches[1]; $ep = $Matches[2]
    } else {
      Log "Skip malformed id: $rid"; continue
    }

    if ($VerboseOutput) { Log "Inspect $ep (ws=$ws)" }
    $curLenJson = az rest -m GET -u "https://management.azure.com$rid?api-version=$API_VERSION" 2>$null
    $curLen = 999
    if ($curLenJson) { try { $curLen = ($curLenJson | ConvertFrom-Json).properties.traffic.psobject.Properties.Count } catch { $curLen = 999 } }
    if ($curLen -eq 0) { continue }

    # Clear traffic via CLI if extension present
    az extension show -n ml *> $null 2>&1
    if ($LASTEXITCODE -eq 0) {
      az ml online-endpoint update -g $rg -w $ws -n $ep --set traffic="{}" *> $null 2>&1 || $true
      $curLenJson = az rest -m GET -u "https://management.azure.com$rid?api-version=$API_VERSION" 2>$null
      if ($curLenJson) { try { $curLen = ($curLenJson | ConvertFrom-Json).properties.traffic.psobject.Properties.Count } catch { } }
    }
    $drainedAny = $true

    # Output updated details like bash script
    $detailsAfter = az rest --method GET --url "https://management.azure.com$rid?api-version=$API_VERSION" 2>$null
    if ($detailsAfter) { Write-Output $detailsAfter }
  }
}

if ($drainedAny) { Log "Drain complete" } else { Log "There was no traffic drain required" }
