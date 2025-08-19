# AI Services Module for Healthcare Agent Orchestrator

This Terraform module deploys Azure OpenAI services required for the Healthcare Agent Orchestrator solution.

## Resources Deployed

- Azure OpenAI Service
- GPT Model Deployment
- Key Vault Secrets (optional)
- Role Assignments (optional)

## Usage

```hcl
module "ai_services" {
  source = "./tf_modules/ai-services-module"

  # Core configuration
  resource_group_name = "hao_0816"
  location            = "westus"
  ai_services_name    = "oai-hao-0816"
  key_vault_id        = module.core.key_vault_id

  # Model configuration
  model_deployment_name = "gpt-4"
  model_name            = "gpt-4"
  model_version         = "0125-preview"
  model_capacity        = 80

  # Security configuration
  user_principal_id     = data.azurerm_client_config.current.object_id
  
  # Tags
  tags = {
    Environment = "Development"
    Project     = "Healthcare Agent Orchestrator"
    Component   = "AI Services"
    ManagedBy   = "Terraform"
  }
}
```

## Required Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| resource_group_name | Name of the resource group | string | yes |
| location | Azure region for AI services | string | yes |
| ai_services_name | Name of the Azure OpenAI service | string | yes |

## Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| key_vault_id | ID of the Key Vault where to store secrets | string | "" |
| openai_sku_name | SKU for the OpenAI service | string | "S0" |
| model_deployment_name | Name of the model deployment | string | "gpt-4" |
| model_name | Name of the OpenAI model to deploy | string | "gpt-4" |
| model_version | Version of the OpenAI model | string | "0125-preview" |
| model_capacity | Capacity/Tokens-per-minute for the model deployment | number | 80 |
| create_role_assignments | Whether to create role assignments | bool | true |
| store_secrets_in_keyvault | Whether to store OpenAI secrets in Key Vault | bool | true |
| user_principal_id | Principal ID of the user to grant access | string | "" |
| service_principal_ids | Map of service principal IDs to grant access | map(string) | {} |
| tags | Tags to apply to all resources | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of the OpenAI service |
| name | Name of the OpenAI service |
| endpoint | Endpoint URL for the OpenAI service |
| primary_access_key | Primary access key for the OpenAI service (sensitive) |
| model_deployment_id | ID of the model deployment |
| model_deployment_name | Name of the model deployment |
| principal_id | Principal ID of the managed identity |

## Notes

- Azure OpenAI services require quota in the subscription
- The deployment of GPT models can take 10-15 minutes
- Role assignments may take some time to propagate
