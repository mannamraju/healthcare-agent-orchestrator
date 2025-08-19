# Healthcare Agent Orchestrator - Comprehensive Fix Guide

This document explains the solutions to all deployment errors encountered in the Healthcare Agent Orchestrator deployment, including the latest issues.

## Latest Errors Fixed

### 1. Azure AD Authentication Error

**Error Message:**
```
Error: building client: unable to obtain access token: running Azure CLI: exit status 1: ERROR: The server or proxy was not found.. Status: Response_Status.Status_NoNetwork, Error code: 3399942148, Tag: 557973641
Please explicitly log in with:
az login --scope https://graph.microsoft.com/.default
```

**Root Cause:**
The Terraform Azure AD provider requires specific Microsoft Graph API permissions that weren't included in the regular Azure authentication.

**Solution:**
- Added explicit Azure CLI login with Microsoft Graph API scope at the start of the deployment script
- Created a separate authentication script (`login_with_graph_scope.ps1`) that can be run independently
- Integrated proper authentication checks in the comprehensive fix script

### 2. Storage Account Key-Based Authentication Error

**Error Message:**
```
Error: retrieving queue properties for Storage Account: unexpected status 403 (403 Key based authentication is not permitted on this storage account.) with KeyBasedAuthenticationNotPermitted: Key based authentication is not permitted on this storage account.
```

**Root Cause:**
The storage accounts were configured with `shared_access_key_enabled = false`, which prevents Terraform from using key-based authentication to manage them.

**Solution:**
- Set `storage_shared_access_key_enabled = true` in the Terraform variables
- Updated the storage account modules' default behavior to enable shared access keys
- Added special handling for storage account deployments in the deployment script

### 3. Endpoint URL Mismatches

**Error Message:**
```
~ azure_openai_api_endpoint = "https://cog-eastus-hao815-gpu.openai.azure.com/" -> (known after apply)
~ azure_openai_endpoint = "https://cog-eastus-hao815-gpu.openai.azure.com/" -> (known after apply)
~ azure_openai_reasoning_model_endpoint = "https://cog-eastus-hao815-gpu.openai.azure.com/" -> (known after apply)
~ keyvault_endpoint = "https://kv-eastus-hao815-fix.vault.azure.net/" -> (known after apply)
```

**Root Cause:**
There's a mismatch between the expected endpoints in the state file and the actual endpoints of the new resources being created. This is likely because you've changed resource names between deployments.

**Solution:**
- Completely new resource naming scheme to avoid conflicts with previous deployments
- Ensured consistent naming between the deployment script, Terraform variables, and outputs
- Set `environment_name` to "hao815fix" to create a clean separation from previous attempts

## Previous Errors Fixed

### 1. Role Assignment Conflicts

**Error Message:**
```
Role assignment already exists
```

**Solution:**
- Set `local.create_role_assignments = false` in the main.tf to prevent creating duplicate role assignments
- Added lifecycle configurations to ignore changes to role assignments

### 2. App Service Plan Quota Issues

**Error Message:**
```
Operation cannot be completed without additional quota. See https://aka.ms/antquotahelp for instructions on requesting limit increases.
```

**Solution:**
- Changed App Service Plan SKU from PremiumV3 to Basic (B1) tier
- Added resource naming with unique suffixes to avoid naming conflicts

### 3. GPT Token Limit Issues

**Error Message:**
```
InsufficientQuota: This operation require 100 new capacity in quota Tokens Per Minute (thousands) - gpt-4o, which is bigger than the current available capacity 50. The current quota usage is 100 and the quota limit is 150 for quota Tokens Per Minute (thousands) - gpt-4o.
```

**Solution:**
- Reduced the requested capacity from 100 TPM to 50 TPM to fit within available quota

## How to Use This Fix

The comprehensive fix addresses all known issues in a single deployment script. To deploy:

1. Run the Azure AD authentication script first (only if prompted):
   ```powershell
   .\login_with_graph_scope.ps1
   ```

2. Run the comprehensive deployment script:
   ```powershell
   .\deploy_hao815_comprehensive_fix.ps1
   ```

3. Monitor the deployment:
   ```powershell
   .\monitor_hao815_deployment_fixed.ps1
   ```

## Requesting Quota Increases

If you need higher tiers or capacities, you should request Azure quota increases:

1. For App Service Plan quota: Azure Portal → Help + Support → New support request → Service and subscription limits (quotas) → App Service Quotas

2. For OpenAI token capacity: Azure Portal → Help + Support → New support request → Service and subscription limits (quotas) → Cognitive Services - Azure OpenAI

## Troubleshooting

If you encounter further issues:

1. **Network Connectivity Issues:**
   - Ensure you have stable internet connectivity
   - Try connecting to Azure from a different network if possible

2. **Authentication Issues:**
   - Run the `login_with_graph_scope.ps1` script explicitly
   - Check if your Azure CLI is properly configured

3. **Resource Naming Conflicts:**
   - Edit `terraform.hao815-comprehensive-fix.tfvars` to use different resource names
   - Consider using a different value for `environment_name`

4. **Quota Issues:**
   - Request quota increases as outlined above
   - Consider deploying in a different Azure region with more available quota
