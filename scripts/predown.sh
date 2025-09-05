#!/usr/bin/env bash
# Terraform-only pre-destroy actions for azd (invoked via the 'predown' hook)
set -euo pipefail

AZURE_YAML="azure.yaml"
if [ ! -f "$AZURE_YAML" ]; then
  echo "predown: azure.yaml not found at expected location: $ROOT_DIR" >&2
  exit 0
fi

provider=$(awk '
  BEGIN{inInfra=0}
  /^[[:space:]]*#/ {next}
  /^[[:space:]]*infra:[[:space:]]*$/ {inInfra=1; next}
  inInfra && /^[^[:space:]]/ {inInfra=0}
  inInfra && /^[[:space:]]*provider:[[:space:]]*/ {
    line=$0
    sub(/^[[:space:]]*provider:[[:space:]]*/,"",line)
    sub(/#.*/, "", line)
    gsub(/"/, "", line)
    sub(/^[[:space:]]+/, "", line)
    sub(/[[:space:]]+$/, "", line)
    print line
    exit
  }
' "$AZURE_YAML" || true)

if [ "${provider:-}" != "terraform" ]; then
  echo "Skipping predown: provider=${provider:-<none>}"
  exit 0
fi

echo "Infra provider is Terraform. Proceeding with pre-destroy scripts..."

run_script() {
  local script_path="$1"
  local label="$2"
  if [ -f "$script_path" ]; then
    echo "Executing $label"
    chmod +x "$script_path" 2>/dev/null || true
    if ! "$script_path"; then
      echo "WARNING: $label failed (continuing)" >&2
    fi
  else
    echo "Skipping $label (not found)"
  fi
}

run_script ./scripts/drain_ml_endpoints.sh "ML endpoint traffic drain pre-destroy (terraform)"
run_script ./scripts/delete_ml_endpoints.sh "ML endpoint resource deletion (terraform)"

exit 0
