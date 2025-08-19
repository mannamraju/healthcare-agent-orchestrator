# AI Services Module for Healthcare Agent Orchestrator
# This module creates Azure OpenAI service and deploys models

# Create the Cognitive Services account for OpenAI
resource "azurerm_cognitive_account" "openai" {
  name                       = var.ai_services_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  kind                       = "OpenAI"
  sku_name                   = var.openai_sku_name
  custom_subdomain_name      = var.ai_services_name
  public_network_access_enabled = true
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# Deploy the GPT model
resource "azurerm_cognitive_deployment" "gpt" {
  name                 = var.model_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id
  
  # Model configuration
  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version
  }
  
  # Scale configuration
  sku {
    name     = "Standard"
    capacity = var.model_capacity
  }
}

# Store the OpenAI endpoint in Key Vault - disabled due to access issues
resource "azurerm_key_vault_secret" "openai_endpoint" {
  count        = 0 # Disabled due to access issues
  name         = "openai-endpoint"
  value        = azurerm_cognitive_account.openai.endpoint
  key_vault_id = var.key_vault_id
}

# Store the OpenAI key in Key Vault - disabled due to access issues
resource "azurerm_key_vault_secret" "openai_key" {
  count        = 0 # Disabled due to access issues
  name         = "openai-key"
  value        = azurerm_cognitive_account.openai.primary_access_key
  key_vault_id = var.key_vault_id
}

# Grant access to the current principal
resource "azurerm_role_assignment" "openai_contributor" {
  count                = var.create_role_assignments ? 1 : 0
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = var.user_principal_id
}

# Grant access to service principals
resource "azurerm_role_assignment" "service_principals" {
  for_each             = var.service_principal_ids
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = each.value
}

# Delay resource to allow role assignments to propagate
resource "time_sleep" "role_assignment_propagation" {
  count = var.create_role_assignments ? 1 : 0
  depends_on = [
    azurerm_role_assignment.openai_contributor,
    azurerm_role_assignment.service_principals
  ]
  
  create_duration = "30s"
}
