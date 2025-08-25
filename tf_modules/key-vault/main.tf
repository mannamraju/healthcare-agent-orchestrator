# Key Vault Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Data source for role definition
data "azurerm_role_definition" "key_vault_secrets_officer" {
  name = "Key Vault Secrets Officer"
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
  role_definition_id   = data.azurerm_role_definition.key_vault_secrets_officer.id
  principal_id         = var.user_principal_id
  principal_type       = var.user_principal_type
}

# Role assignments for service principals - Key Vault Secrets Officer
resource "azurerm_role_assignment" "secrets_officer_msi" {
  for_each = var.service_principal_ids

  scope                = azurerm_key_vault.main.id
  role_definition_id   = data.azurerm_role_definition.key_vault_secrets_officer.id
  principal_id         = each.value
  principal_type       = "ServicePrincipal"
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
