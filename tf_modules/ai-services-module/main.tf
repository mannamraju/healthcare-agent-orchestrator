# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# AI Services Module for Healthcare Agent Orchestrator
# This module creates Azure OpenAI service and deploys models

terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Create the Cognitive Services account for OpenAI
resource "azurerm_ai_services" "ai" {
  name                         = var.ai_services_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  sku_name                     = var.openai_sku_name
  custom_subdomain_name        = var.ai_services_name
  public_network_access        = "Enabled"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

// Update deployment to reference the AI Services account
resource "azurerm_cognitive_deployment" "gpt" {
  name                 = var.model_deployment_name != "" ? var.model_deployment_name : var.model_name
  cognitive_account_id = azurerm_ai_services.ai.id

  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version
  }

  sku {
    name     = "Standard"
    capacity = var.model_capacity
  }
}

# Store the OpenAI endpoint in Key Vault - disabled due to access issues
resource "azurerm_key_vault_secret" "openai_endpoint" {
  count        = 0
  name         = "openai-endpoint"
  value        = azurerm_ai_services.ai.endpoint
  key_vault_id = var.key_vault_id
}

// RBAC: scope to the AI Services account
resource "azurerm_role_assignment" "openai_contributor" {
  count                = var.create_role_assignments ? 1 : 0
  scope                = azurerm_ai_services.ai.id
  role_definition_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/a001fd3d-188f-4b5d-821b-7da978bf7442"
  principal_id         = var.user_principal_id
  principal_type       = "User"
}

resource "azurerm_role_assignment" "service_principals" {
  for_each             = var.service_principal_ids
  scope                = azurerm_ai_services.ai.id
  role_definition_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/a97b65f3-24c7-4388-baec-2e87135dc908"
  principal_id         = each.value
  principal_type       = "ServicePrincipal"
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
