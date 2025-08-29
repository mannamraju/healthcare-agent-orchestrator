#!/usr/bin/env bash
# Drain or delete Azure ML managed online endpoints created by Terraform so destroy won't fail on non-zero traffic.
set -euo pipefail

# Define environment variables
API_VERSION="2024-10-01"
RG=$(azd env get-value AZURE_RESOURCE_GROUP 2>/dev/null || true)
ENV_NAME=$(azd env get-value AZURE_ENV_NAME 2>/dev/null || true)
STATE_FILE=".azure/${ENV_NAME}/terraform.tfstate"
VERBOSE=${VERBOSE:-0}

log(){ echo "[drain-ml] $*"; }
[ -z "$RG" ] && log "No resource group; exiting" && exit 0
[ -z "$ENV_NAME" ] && log "No AZURE_ENV_NAME; exiting" && exit 0
[ ! -f "$STATE_FILE" ] && log "State file not found ($STATE_FILE); exiting" && exit 0

# Retrieve endpoint ids using Terraform state file
endpoint_ids=$(jq -r '.resources[]? | select(.type=="azapi_resource" and .name=="ml_online_endpoint") | .instances[]? | .attributes.id // empty' "$STATE_FILE")
[ -z "$endpoint_ids" ] && log "No ML online endpoints in state" && exit 0

# Install ml extension quietly if missing (ignore failure)
if ! az extension show -n ml >/dev/null 2>&1; then az extension add -n ml -y >/dev/null 2>&1 || true; fi

# Drain traffic
drained_any=0
for rid in $endpoint_ids; do
  details=$(az rest --method GET --url "https://management.azure.com${rid}?api-version=${API_VERSION}" 2>/dev/null || echo '{}')
  echo "$details"
  ws=$(echo "$rid" | awk -F'/workspaces/' '{print $2}' | cut -d'/' -f1)
  ep=$(echo "$rid" | awk -F'/onlineEndpoints/' '{print $2}')
  [ -z "$ws" ] || [ -z "$ep" ] && log "Skip malformed id: $rid" && continue
  [ "$VERBOSE" = 1 ] && log "Inspect $ep (ws=$ws)"
  cur_len=$(az rest -m GET -u "https://management.azure.com${rid}?api-version=${API_VERSION}" 2>/dev/null | jq '.properties.traffic | length' 2>/dev/null || echo 999)
  [ "$cur_len" = 0 ] && continue
  # Try clear via CLI once
  if az extension show -n ml >/dev/null 2>&1; then
    az ml online-endpoint update -g "$RG" -w "$ws" -n "$ep" --set traffic="{}" >/dev/null 2>&1 || true
    cur_len=$(az rest -m GET -u "https://management.azure.com${rid}?api-version=${API_VERSION}" 2>/dev/null | jq '.properties.traffic | length' 2>/dev/null || echo 999)
  fi
  drained_any=1
  details=$(az rest --method GET --url "https://management.azure.com${rid}?api-version=${API_VERSION}" 2>/dev/null || echo '{}')
  echo "$details"
done

[ "$drained_any" = 1 ] && log "Drain complete" || log "There was no traffic drain required"
