# AI Hub deployment for Healthcare Agent Orchestrator
# This configuration uses the ai-hub-module to deploy AI Hub and Project resources

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

# Reference key vault as a resource
resource "null_resource" "key_vault_reference" {
  # Empty block for now - this is just to avoid using data source that might not exist
}

data "azurerm_cognitive_account" "openai" {
  name                = var.ai_services_name
  resource_group_name = data.azurerm_resource_group.core.name
}

# Use data source instead of creating the AI Hub since it already exists in 'global'
data "azurerm_cognitive_account" "ai_hub" {
  name                = var.ai_hub_name
  resource_group_name = var.resource_group_name
}

# Dummy resource to maintain structure but not create anything
resource "null_resource" "ai_project_association" {
  triggers = {
    ai_hub_id = data.azurerm_cognitive_account.ai_hub.id
    ai_project_name = var.ai_project_name
    ai_service_id = data.azurerm_cognitive_account.openai.id
    key_vault_id = var.key_vault_id
  }
}
