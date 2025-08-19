# Healthcare Agent Deployment Guide

This guide walks you through deploying the Healthcare Agent on Azure using the simplified deployment scripts.

## Prerequisites

Before you begin, ensure you have the following:

1. **Azure CLI** installed - [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
2. **Terraform** installed (v1.0+) - [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. **PowerShell** v5.1+ (Windows) or **Bash** (Linux/macOS)
4. **Active Azure subscription** with permissions to create resources
5. Your **Azure Subscription ID** - You can find this in the Azure Portal

## Step 1: Find Your Azure Subscription ID

1. Log in to the [Azure Portal](https://portal.azure.com)
2. Navigate to "Subscriptions" in the left sidebar
3. Copy the Subscription ID you want to use

Alternatively, use the Azure CLI:
```powershell
az login
az account list --output table
```

## Step 2: Create a Resource Group (Optional)

If you don't already have a resource group, create one:
```powershell
az group create --name "your-resource-group-name" --location "westus"
```

## Step 3: Run the Deployment Script

Replace the placeholder values with your actual values:

```powershell
# PowerShell
.\deploy_simplified.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -ResourceGroupName "your-resource-group-name" `
    -EnvironmentName "dev"
```

Or for Bash:
```bash
# Bash
./deploy_simplified.sh \
    --subscription-id "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
    --resource-group "your-resource-group-name" \
    --environment "dev"
```

## Step 4: Testing Without Deployment

To test the configuration without deploying resources:

```powershell
# PowerShell
.\deploy_simplified.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -ResourceGroupName "your-resource-group-name" `
    -EnvironmentName "dev" `
    -TestRun
```

## Troubleshooting

### Common Issues

1. **"Subscription doesn't exist" error**
   - Make sure you're using your actual Azure Subscription ID
   - Don't use the placeholder "your-subscription-id"
   - Verify that you're logged into the correct Azure account

2. **"Resource group doesn't exist" error**
   - Create the resource group first or provide a name for a new one to be created
   
3. **Azure provider authentication errors**
   - Run `az login` manually before executing the script
   - Ensure your Azure account has permission to create resources

4. **Terraform execution errors**
   - Ensure Terraform is properly installed and in your PATH
   - Check if `.terraform` directory exists and delete it if corrupted

## Example with Real Values

```powershell
# Example with fictional values - replace with your actual values
.\deploy_simplified.ps1 `
    -SubscriptionId "12345678-1234-1234-1234-123456789012" `
    -ResourceGroupName "healthcare-agent-rg" `
    -EnvironmentName "dev" `
    -Location "westus" `
    -OpenAIModelCapacity 30 `
    -ClinicalNotesSource "blob"
```

## Getting Help

If you encounter any issues not covered here, please refer to:
- Azure CLI documentation: https://docs.microsoft.com/cli/azure/
- Terraform Azure Provider documentation: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
