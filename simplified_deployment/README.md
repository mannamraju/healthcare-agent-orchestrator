# Healthcare Agent Simplified Deployment

This directory contains a simplified deployment for the Healthcare Agent solution using Terraform.

## Prerequisites

- Azure CLI installed
- Terraform v1.0+ installed
- PowerShell (Windows) or Bash (Linux/macOS)
- Azure subscription with permissions to create resources
- Resource group created in your subscription

## Deployment Architecture

This simplified deployment includes the following Azure resources:

- Azure OpenAI Service with GPT-4o deployment
- Virtual Network with App Service subnet
- Application Insights for monitoring
- FHIR Service (optional, based on configuration)

## Configuration Options

The deployment can be configured using the following parameters:

- `subscription_id`: Your Azure subscription ID
- `resource_group_name`: Name of an existing resource group
- `environment_name`: Environment name (dev, test, prod, etc.)
- `location`: Azure region for deployment (default: westus)
- `openai_model_capacity`: OpenAI model capacity in TPM/1000 (default: 30)
- `clinical_notes_source`: Source for clinical notes (fhir, blob, or fabric) (default: blob)

## Deployment Instructions

### Using PowerShell Script

1. Open PowerShell
2. Navigate to the root directory of the project
3. Run the deployment script:

```powershell
.\deploy_simplified.ps1 `
    -SubscriptionId "your-subscription-id" `
    -ResourceGroupName "your-resource-group" `
    -EnvironmentName "dev"
```

### Manual Terraform Deployment

1. Navigate to the `simplified_deployment` directory
2. Create a `terraform.tfvars` file with your configuration
3. Run the following commands:

```bash
terraform init
terraform validate
terraform plan -out=deploy.tfplan
terraform apply deploy.tfplan
```

## Post-Deployment

After deployment completes, the script will output:

- OpenAI endpoint
- OpenAI deployment name
- Application Insights connection string
- FHIR service endpoint (if deployed)
- App Service subnet ID

## Cleanup

To delete all deployed resources:

```bash
terraform destroy
```

## Troubleshooting

- **Azure login fails**: Ensure you have proper Azure credentials and permissions
- **Resource creation fails**: Check that your subscription has enough quota for the requested resources
- **Network connectivity issues**: Verify that your network allows the necessary outbound connections
