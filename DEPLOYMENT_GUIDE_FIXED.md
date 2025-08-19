# Healthcare Agent Orchestrator Deployment Guide

This guide will help you resume the deployment of Healthcare Agent Orchestrator to your Azure subscription.

## Prerequisites

1. Make sure you have the following tools installed:
   - PowerShell 7+
   - Azure CLI
   - Terraform 1.0+

2. Make sure you're logged in to Azure with the right subscription:

   ```powershell
   az login
   az account set --subscription "69642945-f464-4724-ba83-205eecbe5937"
   ```

## Quick Deployment Steps

1. **Ensure Correct Configuration**: 
   - Your `terraform.tfvars` file should have `openai_model_sku = "GlobalStandard"` (not "Global")
   - `storage_shared_access_key_enabled` should be set to `true`

2. **Run the Deployment Script**:

   ```powershell
   ./resume_deploy.ps1
   ```

3. **Review the Plan**: 
   - Carefully review the Terraform plan before applying
   - Make sure there are no unexpected deletions
   - Confirm the deployment when prompted

4. **Monitor Deployment**:
   - The deployment will display progress in the terminal
   - If any errors occur, note them for troubleshooting

## Troubleshooting Common Issues

If you encounter issues during deployment, use the troubleshooting script:

```powershell
./troubleshoot_deploy.ps1
```

### Common Issues and Solutions:

1. **AI Hub Location Conflict**:
   - Problem: AI Hub resource already exists in "global" location but deployment tries to create it in "westus"
   - Solution: Use data source instead of resource creation (Option 3 in troubleshooter)

2. **Storage Account Key Access Issues**:
   - Problem: Storage account has key-based authentication disabled
   - Solution: Enable shared access key in tfvars (Option 4 in troubleshooter)

3. **Module Path Issues**:
   - Problem: Terraform can't find the right module paths
   - Solution: Fix module paths (Option 2 in troubleshooter)

4. **State Conflicts**:
   - Problem: Resource already exists but Terraform tries to create it
   - Solution: Remove specific resource from state (Option 5 in troubleshooter)

## Post-Deployment Steps

1. **Validate the Deployment**:
   - Check that all resources were created successfully
   - Look for any error messages in the deployment logs

2. **Configure Authentication**:
   - Update any necessary authentication configurations

3. **Test the Healthcare Agent**:
   - Access the Healthcare Agent through the deployed interface
   - Verify that it's functioning correctly

## Support

If you need assistance with the deployment, please refer to the following resources:

- Review the deployment logs in the `logs/` directory
- Check the error messages in the Terraform output
- Use the troubleshooting script for common issues

Remember to keep your deployment scripts and configuration secure, as they may contain sensitive information.
