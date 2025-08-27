# Key Vault Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Subscription and role definition (subscription-scoped like Bicep)
data "azurerm_client_config" "current" {}

# Data source for role definition at subscription scope to match ARM's returned format
data "azurerm_role_definition" "key_vault_secrets_officer" {
  name  = "Key Vault Secrets Officer"
  scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

locals {
  # Explicit subscription-scoped roleDefinitionId (mirrors Bicep)
  kv_secrets_officer_role_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b86a8fe4-44ce-4948-aee5-eccb2c155cd7"
  # Seed used for deterministic GUID names (principal|scope|role)
  kv_ra_seed = "${azurerm_key_vault.main.id}|${local.kv_secrets_officer_role_id}"
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  tags                = var.tags

  sku_name = "standard"

  enable_rbac_authorization     = true
  enabled_for_deployment        = false
  enabled_for_disk_encryption   = false
  enabled_for_template_deployment = false
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }
}

# Role assignment for user principal - Key Vault Secrets Officer
resource "azurerm_role_assignment" "secrets_officer_user" {
  count = var.user_principal_id != "" ? 1 : 0

  scope                = azurerm_key_vault.main.id
  role_definition_id   = local.kv_secrets_officer_role_id
  principal_id         = var.user_principal_id
  principal_type       = var.user_principal_type

  # Deterministic role assignment name (GUID) based on principal/scope/role
  name = lower(format("%s-%s-%s-%s-%s",
    substr(md5("${var.user_principal_id}|${local.kv_ra_seed}"), 0, 8),
    substr(md5("${var.user_principal_id}|${local.kv_ra_seed}"), 8, 4),
    substr(md5("${var.user_principal_id}|${local.kv_ra_seed}"), 12, 4),
    substr(md5("${var.user_principal_id}|${local.kv_ra_seed}"), 16, 4),
    substr(md5("${var.user_principal_id}|${local.kv_ra_seed}"), 20, 12)
  ))
}

# Role assignments for service principals - Key Vault Secrets Officer
resource "azurerm_role_assignment" "secrets_officer_msi" {
  for_each = var.service_principal_ids

  scope                = azurerm_key_vault.main.id
  role_definition_id   = local.kv_secrets_officer_role_id
  principal_id         = each.value
  principal_type       = "ServicePrincipal"

  # Deterministic role assignment name (GUID) based on principal/scope/role
  name = lower(format("%s-%s-%s-%s-%s",
    substr(md5("${each.value}|${local.kv_ra_seed}"), 0, 8),
    substr(md5("${each.value}|${local.kv_ra_seed}"), 8, 4),
    substr(md5("${each.value}|${local.kv_ra_seed}"), 12, 4),
    substr(md5("${each.value}|${local.kv_ra_seed}"), 16, 4),
    substr(md5("${each.value}|${local.kv_ra_seed}"), 20, 12)
  ))
}

# Graph RAG Subscription Key Secret (if provided)
resource "azurerm_key_vault_secret" "graph_rag_subscription_key" {
  count = var.graph_rag_subscription_key != "" ? 1 : 0
  
  name         = "graph-rag-subscription-key"
  value        = var.graph_rag_subscription_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.secrets_officer_user,
    azurerm_role_assignment.secrets_officer_msi
  ]
}
