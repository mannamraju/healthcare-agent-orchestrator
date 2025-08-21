# Healthcare Agent Module for Healthcare Agent Orchestrator
# This module creates Healthcare Agent services and components using proper HealthBot resources
# Based on the bicep implementation to maintain compatibility

# Healthcare Agent Services using Azure HealthBot resource
resource "azurerm_healthbot" "healthcare_agent" {
  for_each = var.healthcare_bots

  name                = lower(each.value.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.bot_sku_name
  
  # Note: Azure HealthBot may not directly support identity blocks in the current provider version
  # We'll use role assignments for managed identity integration instead
  
  tags = merge(var.tags, {
    HealthcareAgentTemplate = "MultiAgentCollaboration"
    AgentTemplate = each.value.name
  })
  
  lifecycle {
    ignore_changes = [tags]
  }
}

# Associate user-assigned managed identity with the health bot
# This would typically be done via an explicit resource association
# For now, we'll use role assignments only since healthbot doesn't support explicit identity association

# Store Healthcare Agent secrets in Key Vault
resource "azurerm_key_vault_secret" "healthcare_agent_secret" {
  for_each = var.healthcare_bots
  
  name         = "HealthcareAgentService-${each.value.name}-Secret"
  value        = "" # This should be updated with the proper secret when available
  key_vault_id = var.key_vault_id
  
  content_type = "text/plain"
  
  lifecycle {
    ignore_changes = [value]
  }
}

# Service principal role assignments
resource "azurerm_role_assignment" "service_principals" {
  for_each             = var.service_principal_ids
  scope                = azurerm_healthbot.healthcare_agent[each.key].id
  role_definition_name = "Contributor"
  principal_id         = each.value
  
  # Add lifecycle to prevent destroy and ignore changes
  lifecycle {
    ignore_changes = [scope, principal_id]
  }
}
