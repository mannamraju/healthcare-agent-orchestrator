# Healthcare Agent Comprehensive Deployment

This directory contains the Terraform configuration for deploying the complete Healthcare Agent solution on Azure.

## Components Deployed

- **Core Infrastructure**
  - Virtual Network with subnets for App Service, private endpoints, and gateway
  - Network Security Groups
  - Private DNS zones for secure networking
  - VPN Gateway (optional)

- **AI Services**
  - Azure AI Foundry (Cognitive Services)
  - Azure AI Hub with Container Registry
  - Azure AI Project
  - GPT-4o model deployment

- **App Services**
  - App Service Plan
  - Healthcare Agent App Service
  - Private endpoints for secure access

- **Storage & Data**
  - Primary Storage Account
  - App Storage Account
  - Event Grid System Topics
  - Storage container for data

- **Security**
  - Key Vault with RBAC authorization
  - Managed Identities for Bot Services
  - Private endpoints for secure access

- **Monitoring**
  - Application Insights

- **Bot Services**
  - Multiple Azure Bots with managed identities

## Prerequisites

- Azure CLI installed and logged in
- Terraform v1.0+ installed
- An Azure subscription
- A resource group (e.g., `hao_0818`)
- Owner or Contributor permissions on the subscription/resource group

## Deployment

### PowerShell

```powershell
.\deploy_comprehensive.ps1 -SubscriptionId "<your-subscription-id>" -ResourceGroup "hao_0818" -EnvironmentName "<env-name>"
```

### Bash

```bash
./deploy_comprehensive.sh <your-subscription-id> hao_0818 <env-name>
```

### Manual Terraform Commands

1. Create a `terraform.tfvars` file in the `comprehensive_deployment` directory:
   ```hcl
   subscription_id     = "<your-subscription-id>"
   resource_group_name = "hao_0818"
   environment_name    = "<env-name>"
   location            = "westus"
   ```

2. Run Terraform commands:
   ```bash
   cd comprehensive_deployment
   terraform init
   terraform plan -out=deployment.tfplan
   terraform apply deployment.tfplan
   ```

## Validation

After deployment, validate that all resources were created successfully:

```powershell
.\validate_comprehensive.ps1 -SubscriptionId "<your-subscription-id>" -ResourceGroup "hao_0818"
```

## Customization

- Edit `terraform.tfvars` to customize resource parameters
- Modify `variables.tf` to add or change variable defaults
- Update module configurations in `main.tf` for specific resource requirements
