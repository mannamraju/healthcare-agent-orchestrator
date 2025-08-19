# Healthcare Agent Simplified Deployment

This project provides a simplified deployment approach for the Healthcare Agent solution on Azure. The deployment creates all necessary Azure resources using Terraform and provides easy-to-use scripts for deployment, validation, and cleanup.

## Quick Start

### PowerShell (Windows)

```powershell
# Deploy
.\deploy_simplified.ps1 -SubscriptionId "your-subscription-id" -ResourceGroupName "your-resource-group" -EnvironmentName "dev"

# Validate
.\validate_simplified.ps1 -SubscriptionId "your-subscription-id" -ResourceGroupName "your-resource-group"

# Cleanup
.\cleanup_simplified.ps1 -SubscriptionId "your-subscription-id" -ResourceGroupName "your-resource-group"
```

### Bash (Linux/macOS)

```bash
# Make scripts executable
chmod +x deploy_simplified.sh cleanup_simplified.sh

# Deploy
./deploy_simplified.sh --subscription-id "your-subscription-id" --resource-group "your-resource-group" --environment "dev"

# Cleanup
./cleanup_simplified.sh --subscription-id "your-subscription-id" --resource-group "your-resource-group"
```

## Deployment Architecture

The simplified deployment creates the following resources:

- Azure OpenAI Service with GPT-4o deployment
- Virtual Network with properly configured subnet
- Application Insights for monitoring
- FHIR Service (optional, based on configuration)

## Configuration Options

The deployment can be customized with the following parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| subscription_id | Azure Subscription ID | Required |
| resource_group_name | Resource Group Name | Required |
| environment_name | Environment identifier (dev, test, prod) | Required |
| location | Azure region | westus |
| openai_model_capacity | OpenAI model capacity (TPM/1000) | 30 |
| clinical_notes_source | Source for clinical notes (fhir, blob, fabric) | blob |

## Directory Structure

- `simplified_deployment/` - Terraform configuration files
  - `main.tf` - Main infrastructure definition
  - `variables.tf` - Variable definitions
  - `outputs.tf` - Output variables
  - `README.md` - Detailed deployment instructions
- `deploy_simplified.ps1` - PowerShell deployment script
- `deploy_simplified.sh` - Bash deployment script
- `validate_simplified.ps1` - PowerShell validation script
- `cleanup_simplified.ps1` - PowerShell cleanup script
- `cleanup_simplified.sh` - Bash cleanup script

## Troubleshooting

- **Azure login issues**: Ensure you have the right permissions in your Azure subscription
- **Resource creation fails**: Check your quota limits and ensure all required providers are registered
- **Network connectivity issues**: Validate that your network allows outbound connectivity to Azure
- **Terraform state issues**: Check if `.terraform` directory exists and contains valid state

## Additional Resources

- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Healthcare Agent Documentation](https://learn.microsoft.com/azure/health/healthcare-apis/healthcare-agent/)
