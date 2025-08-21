# AI Services deployment for Healthcare Agent Orchestrator
# This configuration uses the ai-services-module to deploy OpenAI services

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

# No need to fetch the resource group, we'll create our resources directly

# Reference key vault as a resource
resource "null_resource" "key_vault_reference" {
  # Empty block for now - this is just to avoid using data source that might not exist
}

# Use the AI Services module to create OpenAI service
module "ai_services" {
  source = "../ai-services-module"

  # Core configuration
  resource_group_name = var.resource_group_name
  location            = var.location
  ai_services_name    = var.ai_services_name
  key_vault_id        = var.key_vault_id

  # Model configuration
  model_deployment_name = var.model_deployment_name
  model_name            = var.model_name
  model_version         = var.model_version
  model_capacity        = var.model_capacity

  # Security configuration
  user_principal_id     = data.azurerm_client_config.current.object_id
  
  # Tags
  tags = var.tags
}
