#!/usr/bin/env bash
# Delete Azure ML managed online endpoints and poll until they are gone.
set -euo pipefail
API_VERSION="2024-10-01"
RG=$(azd env get-value AZURE_RESOURCE_GROUP 2>/dev/null || true)
ENV_NAME=$(azd env get-value AZURE_ENV_NAME 2>/dev/null || true)
STATE_FILE=".azure/${ENV_NAME}/terraform.tfstate"
MAX_SECONDS=${MAX_SECONDS:-600}
INTERVAL=${INTERVAL:-15}
log(){ echo "[delete-ml] $*"; }
[ -z "$RG" ] && log "No resource group; exiting" && exit 0
[ -z "$ENV_NAME" ] && log "No AZURE_ENV_NAME; exiting" && exit 0
[ ! -f "$STATE_FILE" ] && log "State file not found ($STATE_FILE); exiting" && exit 0

# TODO: This is very hardcoded, but maybe we can parameterize this better if there are additional endpoints in the future
# Also, resource type may change in the future (right now it's azapi_resource)
endpoint_ids=$(jq -r '.resources[]? | select(.type=="azapi_resource" and .name=="ml_online_endpoint") | .instances[]? | .attributes.id // empty' "$STATE_FILE")
[ -z "$endpoint_ids" ] && log "No ML online endpoints in state" && exit 0

if ! az extension show -n ml >/dev/null 2>&1; then az extension add -n ml -y >/dev/null 2>&1 || true; fi

# Issue deletes (traffic should already be drained by preceding script)
for rid in $endpoint_ids; do
  ws=$(echo "$rid" | awk -F'/workspaces/' '{print $2}' | cut -d'/' -f1)
  ep=$(echo "$rid" | awk -F'/onlineEndpoints/' '{print $2}')
  [ -z "$ws" ] || [ -z "$ep" ] && { log "Skip malformed id: $rid"; continue; }
  log "Deleting endpoint $ep (workspace=$ws)";
  az ml online-endpoint delete -g "$RG" -w "$ws" -n "$ep" --yes --no-wait >/dev/null 2>&1 || true
 done

# Poll
elapsed=0
while [ $elapsed -lt $MAX_SECONDS ]; do
  remaining=0
  for rid in $endpoint_ids; do
    ws=$(echo "$rid" | awk -F'/workspaces/' '{print $2}' | cut -d'/' -f1)
    ep=$(echo "$rid" | awk -F'/onlineEndpoints/' '{print $2}')
    az ml online-endpoint show -g "$RG" -w "$ws" -n "$ep" >/dev/null 2>&1 && remaining=$((remaining+1)) || true
  done
  [ $remaining -eq 0 ] && { log "All endpoints gone after ${elapsed}s"; exit 0; }
  log "$remaining endpoints still present after ${elapsed}s; waiting...";
  sleep $INTERVAL
  elapsed=$((elapsed+INTERVAL))
 done
log "WARNING: Some endpoints still reported after ${MAX_SECONDS}s; continuing anyway."
exit 0
