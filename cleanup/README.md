# Healthcare Agent Orchestrator - Cleanup Module

This Terraform module provides safe and comprehensive cleanup of your healthcare agent orchestrator deployment.

## Features

- **Safe Cleanup**: Requires explicit confirmation before proceeding
- **Dependency-Aware**: Deletes resources in proper order to avoid dependency conflicts
- **Data Preservation**: Option to preserve storage accounts and data during cleanup
- **Force Cleanup**: Option to force delete stuck resources
- **Comprehensive Logging**: Detailed output of cleanup operations
- **Validation**: Pre-cleanup validation and resource inventory

## Quick Start

### 1. Review Resources to be Deleted

```bash
cd cleanup
terraform init
terraform plan
```

### 2. Safe Cleanup (Preserves Data)

```bash
# Edit terraform.tfvars and set:
# confirm_destroy = "yes"
# preserve_data = true

terraform apply
```

### 3. Complete Cleanup

```bash
# Edit terraform.tfvars and set:
# confirm_destroy = "yes"
# preserve_data = false

terraform apply
```

## Configuration Options

### terraform.tfvars

```hcl
# Required: Resource group to cleanup
resource_group_name = "hao070909_fresh"

# Safety confirmation - MUST be set to "yes" to proceed
confirm_destroy = "yes"

# Data preservation options
preserve_data = false   # Set to true to keep storage accounts

# Force cleanup options  
force_cleanup = false   # Set to true for aggressive cleanup
```

## Cleanup Order

The module deletes resources in this order to handle dependencies:

1. **Bot Services** - Teams channels and bot registrations
2. **Web Apps** - App services and service plans
3. **AI/ML Workspaces** - AI projects and hubs
4. **Cognitive Services** - OpenAI and other AI services
5. **Key Vaults** - With proper purge handling
6. **Managed Identities** - Service principals and identities
7. **Storage Accounts** - (Optional based on preserve_data)
8. **Resource Group** - If empty or force_cleanup=true

## Safety Features

### Confirmation Required
- Must set `confirm_destroy = "yes"` to proceed
- Prevents accidental deletion

### Pre-Cleanup Validation
- Lists all resources to be deleted
- Identifies protected resources (tagged with Protected=true)
- Validates resource group exists

### Data Preservation
- `preserve_data = true` keeps storage accounts and data
- Useful for temporary cleanup or testing

### Force Cleanup
- `force_cleanup = true` attempts to delete stuck resources
- Continues on errors instead of stopping
- Use with caution

## Usage Examples

### Development Environment Cleanup
```bash
# Quick cleanup preserving important data
echo 'confirm_destroy = "yes"
preserve_data = true' > terraform.tfvars

terraform apply
```

### Complete Environment Removal
```bash
# Full cleanup including all data
echo 'confirm_destroy = "yes"
preserve_data = false' > terraform.tfvars

terraform apply
```

### Troubleshooting Stuck Resources
```bash
# Aggressive cleanup for stuck deployments
echo 'confirm_destroy = "yes"
preserve_data = false
force_cleanup = true' > terraform.tfvars

terraform apply
```

## Manual Cleanup (Fallback)

If the Terraform cleanup fails, you can use Azure CLI:

```bash
# List resources in the group
az resource list --resource-group hao070909_fresh --output table

# Delete specific resource types
az botservice list --resource-group hao070909_fresh --query "[].name" -o tsv | \
  xargs -I {} az botservice delete --name {} --resource-group hao070909_fresh --yes

# Delete the entire resource group (nuclear option)
az group delete --name hao070909_fresh --yes --no-wait
```

## Troubleshooting

### Common Issues

1. **Key Vault Purge Protection**
   - Key vaults may require manual purge
   - Use: `az keyvault purge --name <vault-name>`

2. **AI Workspace Dependencies**
   - AI projects must be deleted before AI hubs
   - Module handles this automatically

3. **Role Assignment Conflicts**
   - May need to wait for async deletions
   - Use `force_cleanup = true` if needed

4. **Storage Account Access Keys**
   - Disabled access keys don't prevent deletion
   - Storage accounts delete normally

### Logs and Monitoring

The cleanup module provides detailed logging:
- Resource inventory before cleanup
- Step-by-step deletion progress
- Error handling and continuation logic
- Final cleanup summary

### Recovery

If you need to recreate the environment:
1. Run cleanup with `preserve_data = true`
2. Deploy fresh infrastructure with original Terraform
3. Data in preserved storage accounts will be available

## Security Notes

- Never commit `terraform.tfvars` with `confirm_destroy = "yes"`
- Review the resource list before confirming cleanup
- Consider backup of critical data before cleanup
- Use `preserve_data = true` for development environments

## Support

For issues with cleanup:
1. Check Azure Activity Log for detailed error messages
2. Use `force_cleanup = true` for stuck resources
3. Manual Azure CLI cleanup as fallback
4. Contact Azure support for persistent issues
