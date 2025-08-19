# Healthcare Agent Orchestrator - US West Deployment

This document provides guidance for deploying the Healthcare Agent Orchestrator (HAO) to the US West region, including how to set up core infrastructure components and deploy the complete solution.

## Prerequisites

- Azure CLI installed and updated
- Azure subscription with appropriate permissions
- Terraform 1.0.0 or later
- PowerShell Core (pwsh)

## Deployment Process

The deployment is split into two phases:
1. Core infrastructure deployment (resource group, storage, virtual network)
2. Complete Terraform deployment of all HAO components

### Phase 1: Core Infrastructure Deployment

This phase deploys the fundamental Azure resources needed for the deployment:

```powershell
# Run the core infrastructure deployment script
.\deploy_hao_0816_west.ps1
```

This script will:
- Authenticate to Azure with the required Graph API scope
- Set the subscription context
- Create the resource group `hao_0816` in US West
- Deploy a storage account for Terraform state and application data
- Create a virtual network with a default subnet
- Generate a Terraform variables file for the complete deployment

### Phase 2: Complete Terraform Deployment

After the core infrastructure is in place, run the complete Terraform deployment:

```powershell
# Run the complete Terraform deployment
.\deploy_hao_0816_west_terraform.ps1
```

This script will:
- Deploy all remaining HAO components using Terraform
- Use a staged approach for critical resources
- Generate outputs and save them to a JSON file

## Resource Configuration

The deployment uses the following configuration:

- **Resource Group**: hao_0816
- **Region**: US West
- **Storage Account**: sthao0816west
- **Virtual Network**: vnet-hao-0816-west
- **Subnet**: default (10.0.0.0/24)
- **App Service Plan**: Standard tier (S1)
- **OpenAI Model**: gpt-4o with 50K TPM capacity

## Monitoring the Deployment

You can monitor the deployment process using:

```powershell
# View the latest logs
Get-Content -Path ".\logs\deployment_west_0816_*.log" -Tail 20 -Wait
```

## Post-Deployment Steps

After successful deployment:

1. **Verify Resources**: Check the Azure portal to confirm all resources are provisioned correctly
2. **Access Endpoints**: Use the outputs in `terraform-outputs-hao0816-west.json` to access the application endpoints
3. **Configure Networking**: If needed, further configure network security rules for the virtual network

## Troubleshooting

If you encounter issues during deployment:

1. **Authentication Issues**: Run `az login --scope https://graph.microsoft.com/.default` manually
2. **Resource Conflicts**: Check for name conflicts in the Azure portal
3. **Quota Issues**: Verify your subscription has sufficient quota for the requested resources
4. **Terraform Errors**: Check the detailed error message in the logs

## Support

For assistance with this deployment, contact the Healthcare Agent Orchestrator team.
