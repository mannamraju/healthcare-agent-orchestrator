# Example usage of the Healthcare Agent Module

# First, import the necessary providers
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.53.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group to contain the resources
resource "azurerm_resource_group" "example" {
  name     = "rg-healthcare-example"
  location = "westus2"
}

# Create a Key Vault for storing secrets
resource "azurerm_key_vault" "example" {
  name                = "kv-healthcare-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  purge_protection_enabled = false
}

# Get current client config for role assignments
data "azurerm_client_config" "current" {}

# Use the healthcare-agent-module
module "healthcare_agent" {
  source = "../../tf_modules/healthcare-agent-module"

  healthcare_agent_name = "hao-agent-example"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  
  tags = {
    Environment = "Example"
    Project     = "Healthcare Agent Demo"
  }

  key_vault_id = azurerm_key_vault.example.id
  
  # Define healthcare bots
  healthcare_bots = {
    "radiology" = {
      name = "radiology-bot"
    },
    "clinical_guidelines" = {
      name = "clinical-guidelines-bot"
    },
    "patient_history" = {
      name = "patient-history-bot"
    }
  }
  
  # Role assignments
  create_role_assignments = true
  user_principal_id       = data.azurerm_client_config.current.object_id
  
  # Empty service principals map for this example
  service_principal_ids = {}
}

# Output the important values
output "healthcare_agent_endpoint" {
  value = module.healthcare_agent.healthcare_agent_endpoint
}

output "healthcare_bots" {
  value = module.healthcare_agent.healthcare_bots
}
