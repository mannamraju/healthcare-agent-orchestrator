# Healthcare Agent deployment for Healthcare Agent Orchestrator
# This configuration uses the healthcare-agent-module to deploy Healthcare Agent services

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Fetch the existing resource group
data "azurerm_resource_group" "core" {
  name = var.resource_group_name
}

# Fetch the existing Key Vault
data "azurerm_key_vault" "core" {
  name                = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.core.name
}

# Fetch the existing AI Services
data "azurerm_cognitive_account" "ai_services" {
  name                = var.ai_services_name
  resource_group_name = data.azurerm_resource_group.core.name
}

# Fetch the existing AI Hub
data "azurerm_cognitive_account" "ai_hub" {
  name                = var.ai_hub_name
  resource_group_name = data.azurerm_resource_group.core.name
}

# Use the Healthcare Agent module to create Healthcare Agent services
module "healthcare_agent" {
  source = "../tf_modules/healthcare-agent-module"

  # Core configuration
  healthcare_agent_name = var.healthcare_agent_name
  location              = var.location != "" ? var.location : data.azurerm_resource_group.core.location
  resource_group_name   = data.azurerm_resource_group.core.name
  tags                  = var.tags
  bot_sku_name          = var.bot_sku_name

  # Healthcare bots configuration
  healthcare_bots       = var.healthcare_bots

  # Integration with existing resources
  key_vault_id          = data.azurerm_key_vault.core.id
  
  # Security configuration
  create_role_assignments = var.create_role_assignments
  user_principal_id       = data.azurerm_client_config.current.object_id
  ai_hub_principal_id     = data.azurerm_cognitive_account.ai_hub.identity[0].principal_id
  openai_principal_id     = data.azurerm_cognitive_account.ai_services.identity[0].principal_id
  
  # Service principal IDs for role assignments
  service_principal_ids = var.service_principal_ids
}
