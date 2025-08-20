# Healthcare Agent Module

This Terraform module creates and configures Azure Healthcare Agent services and related components for the Healthcare Agent Orchestrator.

## Resources Created

- Azure HealthBot Service for each specified healthcare agent
- Key Vault Secrets for each Healthcare Agent
- Role assignments for users and service principals

## Usage

```hcl
module "healthcare_agent" {
  source = "./tf_modules/healthcare-agent-module"

  healthcare_agent_name = "hao-agent-dev"
  location              = "westus2"
  resource_group_name   = "rg-healthcare-dev"
  tags                  = { Environment = "Development" }

  key_vault_id          = module.key_vault.id
  
  # Healthcare bots configuration
  healthcare_bots = {
    "radiology" = {
      name = "radiology-agent"
    },
    "clinicalguidelines" = {
      name = "clinical-guidelines-agent"
    }
  }
  
  # Role assignments
  create_role_assignments = true
  user_principal_id       = "00000000-0000-0000-0000-000000000000"
  ai_hub_principal_id     = module.ai_hub.ai_hub_principal_id
  openai_principal_id     = module.ai_services.principal_id
  
  # Service principals for agents
  service_principal_ids = {
    "agent1" = "11111111-1111-1111-1111-111111111111"
    "agent2" = "22222222-2222-2222-2222-222222222222"
  }
}
```

## Input Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `healthcare_agent_name` | The name of the Healthcare Agent Service Account | `string` | |
| `resource_group_name` | The name of the resource group | `string` | |
| `location` | The Azure region where resources will be created | `string` | |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` |
| `bot_sku_name` | The SKU name for the healthcare bot | `string` | `"F0"` |
| `healthcare_bots` | Map of healthcare bots to create | `map(object({ name = string }))` | `{}` |
| `key_vault_id` | The ID of the Key Vault to store secrets | `string` | `""` |
| `create_role_assignments` | Whether to create role assignments | `bool` | `true` |
| `user_principal_id` | The principal ID of the current user | `string` | `""` |
| `ai_hub_principal_id` | The principal ID of the AI Hub service | `string` | `""` |
| `openai_principal_id` | The principal ID of the OpenAI service | `string` | `""` |
| `service_principal_ids` | Map of service principal IDs | `map(string)` | `{}` |

## Output Values

| Name | Description |
|------|-------------|
| `healthcareAgentServiceEndpoints` | Array of Healthcare Agent Service endpoints with management portal links and key vault secret keys |
| `healthcare_bots` | Map of created healthcare bots with their IDs |

## Notes

- Each HealthBot service is created with its own identity and configuration
- Role assignments can be disabled by setting `create_role_assignments` to `false`
- Aligns with the Bicep implementation of Microsoft.HealthBot/healthBots resources
