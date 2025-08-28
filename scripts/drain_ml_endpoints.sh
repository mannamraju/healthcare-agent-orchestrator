#!/usr/bin/env bash
# Drain (remove) traffic assignments from all Azure ML managed online endpoints in the resource group
# so that Terraform can delete the deployments/endpoints without 400 errors about non-zero traffic.
set -euo pipefail

echo "[drain-ml] Starting traffic drain for ML online endpoints defined in Terraform state"

# Helper: run a command, but don't exit script on failure for that command
run_allow_fail() {
  set +e
  "$@"
  local ec=$?
  set -e
  return $ec
}

# Discover resource group via azd env
RG="$(azd env get-value AZURE_RESOURCE_GROUP 2>/dev/null || echo '')"
if [ -z "$RG" ]; then
  echo "[drain-ml] Could not determine AZURE_RESOURCE_GROUP from azd env; skipping ML endpoint drain"
  exit 0
fi

SUB_ID="$(az account show --query id -o tsv)"
API_VERSION="2024-10-01"

ENV_NAME="$(azd env get-value AZURE_ENV_NAME 2>/dev/null || echo '')"
STATE_JSON=""
if [ -n "$ENV_NAME" ]; then
  STATE_FILE=".azure/${ENV_NAME}/terraform.tfstate"
  if [ -f "$STATE_FILE" ]; then
    echo "[drain-ml] Reading state file $STATE_FILE"
    STATE_JSON="$(cat "$STATE_FILE" 2>/dev/null || echo '')"
  else
    echo "[drain-ml] Local state file not found at $STATE_FILE"
  fi
else
  echo "[drain-ml] AZURE_ENV_NAME not set; cannot derive local state path"
fi

if [ -z "$STATE_JSON" ]; then
  echo "[drain-ml] WARNING: Could not obtain Terraform state; skipping ML drain"
  exit 0
fi

## state already validated above

# Extract endpoint resource IDs for azapi_resource.ml_online_endpoint instances
endpoint_ids=$(echo "$STATE_JSON" | jq -r '
  .resources[]? | select(.type=="azapi_resource" and .name=="ml_online_endpoint") | .instances[]? | .attributes.id // empty' 2>/dev/null || true)

if [ -z "$endpoint_ids" ]; then
  echo "[drain-ml] No ml_online_endpoint resources in state; nothing to drain"
  exit 0
fi

patched_any=false

for rid in $endpoint_ids; do
  # rid example: /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.MachineLearningServices/workspaces/<ws>/onlineEndpoints/<ep>
  ws=$(echo "$rid" | awk -F'/workspaces/' '{print $2}' | cut -d'/' -f1)
  ep=$(echo "$rid" | awk -F'/onlineEndpoints/' '{print $2}')
  if [ -z "$ws" ] || [ -z "$ep" ]; then
    echo "[drain-ml] Skipping malformed id: $rid"
    continue
  fi
  echo "[drain-ml] Inspecting endpoint $ep (workspace $ws)"
  details=$(az rest --method GET --url "https://management.azure.com${rid}?api-version=${API_VERSION}" 2>/dev/null || echo '{}')
  echo "$details"
  traffic_len=$(echo "$details" | jq '.properties.traffic | length' 2>/dev/null || echo '0')
  if [ "$traffic_len" = "0" ]; then
    echo "[drain-ml]   Traffic already empty"
    continue
  fi
  echo "[drain-ml]   Attempting az ml CLI traffic clear ($traffic_len assignments)"
  # Ensure ml extension present
  if ! az extension show -n ml >/dev/null 2>&1; then
    echo "[drain-ml]   Installing Azure ML CLI extension"
    run_allow_fail az extension add -n ml -y >/dev/null || echo "[drain-ml]   WARNING: Failed to install ml extension; will try REST delete fallback"
  fi

  cleared=false
  if az extension show -n ml >/dev/null 2>&1; then
    if run_allow_fail az ml online-endpoint update -g "$RG" -w "$ws" -n "$ep" --set traffic="{}" >/dev/null; then
      cur_len=$(az rest --method GET --url "https://management.azure.com${rid}?api-version=${API_VERSION}" 2>/dev/null | jq '.properties.traffic | length' 2>/dev/null || echo '999')
      if [ "$cur_len" = "0" ]; then
        echo "[drain-ml]   Traffic cleared via az ml"
        cleared=true
        patched_any=true
      else
        echo "[drain-ml]   Traffic still $cur_len after single update"
      fi
    else
      echo "[drain-ml]   WARNING: az ml update command failed for $ep"
    fi
  fi

  if [ "$cleared" != true ]; then
    echo "[drain-ml]   Traffic not cleared; deleting endpoint $ep (cascade delete of deployments)"
    if run_allow_fail az rest --method DELETE --url "https://management.azure.com${rid}?api-version=${API_VERSION}" >/dev/null; then
      echo "[drain-ml]   Delete issued for endpoint $ep"
      patched_any=true
    else
      echo "[drain-ml]   ERROR: Failed to delete endpoint $ep"
    fi
  fi
done

if [ "$patched_any" = true ]; then
  echo "[drain-ml] Completed traffic drain"
else
  echo "[drain-ml] No traffic needed clearing"
fi
