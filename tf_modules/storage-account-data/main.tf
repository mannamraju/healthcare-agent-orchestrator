# Storage Account Data Module - Skip direct access
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Data source for role definition
data "azurerm_role_definition" "storage_blob_data_contributor" {
  name = "Storage Blob Data Contributor"
}

# Instead of accessing the storage account directly, we'll just document
# what we need without triggering API calls to the storage account
locals {
  storage_account_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.name}"
  blob_endpoint = "https://${var.name}.blob.core.windows.net/"
  container_names = {
    chat_artifacts = "chat-artifacts"
    chat_sessions = "chat-sessions"
    patient_data = "patient-data"
  }
}

# Role assignment for user principal - Storage Blob Data Contributor
resource "azurerm_role_assignment" "blob_data_contributor_user" {
  count = var.user_principal_id != "" ? 1 : 0

  # Construct the ID without using the data source
  scope                = local.storage_account_id
  role_definition_id   = data.azurerm_role_definition.storage_blob_data_contributor.id
  principal_id         = var.user_principal_id
  principal_type       = var.user_principal_type
}

# Role assignments for service principals - Storage Blob Data Contributor
resource "azurerm_role_assignment" "blob_data_contributor_msi" {
  for_each = var.service_principal_ids

  # Construct the ID without using the data source
  scope                = local.storage_account_id
  role_definition_id   = data.azurerm_role_definition.storage_blob_data_contributor.id
  principal_id         = each.value
  principal_type       = "ServicePrincipal"
}
