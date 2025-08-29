# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# AI Hub deployment for Healthcare Agent Orchestrator
# This configuration uses the ai-hub-module to deploy AI Hub and Project resources

terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}

# Get current subscription id for roleDefinitionId construction
data "azurerm_client_config" "current" {}

resource "azurerm_ai_foundry" "ai_hub" {
  name                = var.ai_hub_name
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
  key_vault_id        = var.key_vault_id
  storage_account_id  = var.storage_account_id
  public_network_access = "Enabled"
  friendly_name       = var.ai_hub_name
  container_registry_id = azurerm_container_registry.acr.id
  tags                = var.tags
}

## Associate AI Hub with AI Services via an ML workspace connection (AzAPI)
resource "azapi_resource" "ai_services_connection" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-04-01"
  name      = substr("${var.ai_hub_name}-connection-AIServices", 0, 32)
  parent_id = azurerm_ai_foundry.ai_hub.id

  body = {
    properties = {
      category      = "AIServices"
      target        = var.ai_services_endpoint
      authType      = "AAD"
      isSharedToAll = true
      metadata = {
        ApiType              = "Azure"
        ResourceId           = var.openai_account_id
        ApiVersion           = "2023-07-01-preview"
        DeploymentApiVersion = "2023-10-01-preview"
        Location             = var.location
      }
    }
  }
}

# AI Project (Azure ML Workspace with kind=Project) linked to hub
resource "azurerm_ai_foundry_project" "ai_project" {
  name               = var.ai_project_name
  location           = var.location
  ai_services_hub_id = azurerm_ai_foundry.ai_hub.id
  identity {
    type = "SystemAssigned"
  }
  friendly_name      = var.ai_project_name
  tags               = var.tags
}

# Add a delay after endpoint deletion to ensure eventual consistency
# before proceeding with workspace deletion.
resource "time_sleep" "post_endpoint_delete_pause" {
  destroy_duration = "90s"

  depends_on = [
    azurerm_ai_foundry_project.ai_project
  ]
}

resource "azurerm_container_registry" "acr" {
  name                = replace("${var.ai_hub_name}-registry", "-", "")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

## Role assignments parity with Bicep
locals {
  ai_developer_role_id     = "64702f94-c441-49e6-a78b-ef80e0188fee"
  openai_contributor_role  = "a001fd3d-188f-4b5d-821b-7da978bf7442"
  subscription_id_from_hub = data.azurerm_client_config.current.subscription_id
}

resource "azurerm_role_assignment" "ai_developer_hub" {
  for_each             = var.create_role_assignments ? merge(var.service_principal_ids, (var.user_principal_id != "" ? { user = var.user_principal_id } : {})) : {}
  scope                = azurerm_ai_foundry.ai_hub.id
  role_definition_id   = "/subscriptions/${local.subscription_id_from_hub}/providers/Microsoft.Authorization/roleDefinitions/${local.ai_developer_role_id}"
  principal_id         = each.value
  principal_type       = each.key == "user" ? var.user_principal_type : "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "ai_developer_project" {
  for_each             = var.create_role_assignments ? merge(var.service_principal_ids, (var.user_principal_id != "" ? { user = var.user_principal_id } : {})) : {}
  scope                = azurerm_ai_foundry_project.ai_project.id
  role_definition_id   = "/subscriptions/${local.subscription_id_from_hub}/providers/Microsoft.Authorization/roleDefinitions/${local.ai_developer_role_id}"
  principal_id         = each.value
  principal_type       = each.key == "user" ? var.user_principal_type : "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "openai_contributor_from_project" {
  count                = var.create_role_assignments ? 1 : 0
  scope                = var.openai_account_id
  role_definition_id   = "/subscriptions/${local.subscription_id_from_hub}/providers/Microsoft.Authorization/roleDefinitions/${local.openai_contributor_role}"
  principal_id         = azurerm_ai_foundry_project.ai_project.identity[0].principal_id
  principal_type       = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
