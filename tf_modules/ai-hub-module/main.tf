# AI Hub Module for Healthcare Agent Orchestrator
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# This module creates or references Azure AI Hub for Healthcare Agent Orchestrator

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}

# Create the AI Hub / Cognitive Services Account
resource "azurerm_cognitive_account" "ai_hub" {
  name                       = var.ai_hub_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  kind                       = "CognitiveServices"
  sku_name                   = "S0"
  custom_subdomain_name      = var.ai_hub_name
  public_network_access_enabled = true
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(var.tags, {
    AIProject = var.ai_project_name
    AIServiceConnection = var.ai_services_id
  })
  
  lifecycle {
    ignore_changes = [tags]
  }
}

# Since azurerm_cognitive_project is not available, we'll use tags and metadata
# to associate the AI Hub with the project and services
resource "null_resource" "ai_project_association" {
  triggers = {
    ai_hub_id = data.azurerm_cognitive_account.ai_hub.id
    ai_project_name = var.ai_project_name
    ai_service_id = var.ai_services_id
    key_vault_id = var.key_vault_id
  }
}

# Store AI Hub connection info in Key Vault if needed
resource "azurerm_key_vault_secret" "ai_hub_endpoint" {
  count        = 0 # Disabling for now to avoid count errors
  name         = "ai-hub-endpoint"
  value        = data.azurerm_cognitive_account.ai_hub.endpoint
  key_vault_id = var.key_vault_id
}

# Role assignments
resource "azurerm_role_assignment" "ai_hub_contributor" {
  count                = 0 # Disabling for now to avoid count errors
  scope                = azurerm_cognitive_account.ai_hub.id
  role_definition_id   = "/providers/Microsoft.Authorization/roleDefinitions/249d5a0a-d227-4cdc-b2b0-92d0d4f6e9c2" # Cognitive Services Contributor
  principal_id         = var.user_principal_id
  principal_type       = "User"
  
  lifecycle {
    ignore_changes = [scope, principal_id]
  }
}

# Service principal role assignments
resource "azurerm_role_assignment" "service_principals" {
  for_each             = var.service_principal_ids
  scope                = azurerm_cognitive_account.ai_hub.id
  role_definition_id   = "/providers/Microsoft.Authorization/roleDefinitions/05b39039-e717-4e44-90f3-bfd684de6d3d" # Cognitive Services User
  principal_id         = each.value
  principal_type       = "ServicePrincipal"
  
  lifecycle {
    ignore_changes = [scope, principal_id]
  }
}

# Storage account for AI Hub
resource "azurerm_storage_account" "ai_hub" {
  count                     = var.create_storage ? 1 : 0
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  
  min_tls_version           = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled = var.shared_access_key_enabled
  
  tags = var.tags
}

# Delay resource to allow role assignments to propagate
resource "time_sleep" "role_assignment_propagation" {
  count = var.create_role_assignments ? 1 : 0
  depends_on = [
    azurerm_role_assignment.ai_hub_contributor,
    azurerm_role_assignment.service_principals
  ]
  
  create_duration = "30s"
}
