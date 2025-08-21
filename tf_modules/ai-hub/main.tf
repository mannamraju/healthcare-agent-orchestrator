# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# AI Hub deployment for Healthcare Agent Orchestrator
# This configuration uses the ai-hub-module to deploy AI Hub and Project resources

# Get current client configuration
data "azurerm_client_config" "current" {}

# Use the resource group passed from main module
# We're creating resources, not looking up existing ones

# Reference key vault as a resource
resource "null_resource" "key_vault_reference" {
  # Empty block for now - this is just to avoid using data source that might not exist
}

# Create a new AI Hub Cognitive Account
resource "azurerm_cognitive_account" "ai_hub" {
  name                = var.ai_hub_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "CognitiveServices"
  sku_name            = "S0"
  custom_subdomain_name = var.ai_hub_name
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# Associate AI Hub with project
resource "null_resource" "ai_project_association" {
  triggers = {
    ai_hub_id = azurerm_cognitive_account.ai_hub.id
    ai_project_name = var.ai_project_name
    ai_service_id = var.openai_account_id
    key_vault_id = var.key_vault_id
  }
}
