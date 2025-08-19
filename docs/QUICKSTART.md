# Simplified Deployment Quick Start

This quick start guide will help you deploy the Healthcare Agent in just a few minutes.

## Step 1: Find Your Azure Subscription ID

Run this command in PowerShell or Command Prompt:
```
az login
az account list --output table
```

Copy your Subscription ID from the output.

## Step 2: Deploy the Healthcare Agent

Run the PowerShell script with your actual values:
```powershell
.\deploy_simplified.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -ResourceGroupName "healthcare-agent-rg" `
    -EnvironmentName "dev"
```

## Step 3: Validate the Deployment

After deployment completes, validate it:
```powershell
.\validate_simplified.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -ResourceGroupName "healthcare-agent-rg"
```

## Step 4: Access the Deployment

1. Log in to the [Azure Portal](https://portal.azure.com)
2. Navigate to your resource group
3. View the deployed resources

## Need More Help?

See the detailed [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for complete instructions and troubleshooting.
