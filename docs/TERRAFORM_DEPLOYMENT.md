# Healthcare Agent - Direct Terraform Deployment

This guide provides straightforward instructions for deploying the Healthcare Agent using direct Terraform commands.

## Prerequisites

- Azure CLI installed and logged in
- Terraform v1.0+ installed
- An Azure subscription and resource group

## Quick Start Deployment

### 1. Set Your Deployment Values

Create a `terraform.tfvars` file in the `simplified_deployment` directory with your actual values:

```hcl
subscription_id      = "12345678-1234-1234-1234-123456789012"
resource_group_name  = "healthcare-agent-rg"
environment_name     = "dev"
location             = "westus"
openai_model_capacity = 30
clinical_notes_source = "blob"  # Options: "fhir", "blob", "fabric"
```

### 2. Using the Deployment Script

#### PowerShell
```powershell
.\terraform_deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -ResourceGroup "healthcare-agent-rg" -EnvironmentName "dev"
```

#### Bash
```bash
./terraform_deploy.sh 12345678-1234-1234-1234-123456789012 healthcare-agent-rg dev
```

### 3. Manual Terraform Commands

If you prefer running Terraform commands directly:

```bash
# Navigate to the deployment directory
cd simplified_deployment

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -out=deployment.tfplan

# Apply the deployment
terraform apply deployment.tfplan

# View outputs
terraform output
```

## Cleanup

### Using Script
```powershell
.\terraform_cleanup.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -ResourceGroup "healthcare-agent-rg"
```

### Manual Terraform Commands
```bash
cd simplified_deployment
terraform destroy
```

## Troubleshooting

- **Subscription ID issues**: Make sure you're using your actual Azure Subscription ID
- **Provider errors**: Try running `terraform init -upgrade` to update providers
- **Resource group not found**: Create the resource group first using Azure CLI
- **Authorization errors**: Run `az login` to refresh credentials

## Resources Created

This deployment will create the following resources:
- Azure OpenAI Service with GPT-4o model
- Virtual Network with configured subnet
- Application Insights
- Optional FHIR Service (if clinical_notes_source is set to "fhir")
