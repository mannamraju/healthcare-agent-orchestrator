# Storage Account Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Data source for role definition
data "azurerm_role_definition" "storage_blob_data_contributor" {
  name = "Storage Blob Data Contributor"
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  tags                     = var.tags

  https_traffic_only_enabled     = true
  min_tls_version               = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled     = var.shared_access_key_enabled
}

# Blob containers
resource "azurerm_storage_container" "chat_artifacts" {
  name                  = "chat-artifacts"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "chat_sessions" {
  name                  = "chat-sessions"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "patient_data" {
  name                  = "patient-data"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# Role assignment for user principal - Storage Blob Data Contributor
resource "azurerm_role_assignment" "blob_data_contributor_user" {
  count = var.user_principal_id != "" ? 1 : 0

  scope                = azurerm_storage_account.main.id
  role_definition_id   = data.azurerm_role_definition.storage_blob_data_contributor.id
  principal_id         = var.user_principal_id
  principal_type       = var.user_principal_type
}

# Role assignments for service principals - Storage Blob Data Contributor
resource "azurerm_role_assignment" "blob_data_contributor_msi" {
  for_each = var.service_principal_ids

  scope                = azurerm_storage_account.main.id
  role_definition_id   = data.azurerm_role_definition.storage_blob_data_contributor.id
  principal_id         = each.value
  principal_type       = "ServicePrincipal"
}
