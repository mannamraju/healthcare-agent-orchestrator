# Healthcare Agent Module for Healthcare Agent Orchestrator
# This module creates Healthcare Agent services and components using compatible resources
# Based on the bicep implementation to maintain compatibility

# Healthcare Agent Services Account (using Cognitive Services as a substitute)
resource "azurerm_cognitive_account" "healthcare_agent" {
  name                = var.healthcare_agent_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "CognitiveServices"
  sku_name            = "S0"  # F0 is not valid for CognitiveServices, using S0 instead
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(var.tags, {
    ResourceType = "Healthcare Agent Service"
  })
  
  lifecycle {
    ignore_changes = [tags]
  }
}

# Instead of creating Web Apps, we'll register the bot connections through metadata
# This aligns with the bicep implementation where bots are registered in the bot service module
resource "null_resource" "healthcare_bot_associations" {
  for_each = var.healthcare_bots
  
  triggers = {
    healthcare_agent_id = azurerm_cognitive_account.healthcare_agent.id
    bot_name = each.value.name
  }
}

# Store Healthcare Agent endpoint in Key Vault - disabled due to access issues
resource "azurerm_key_vault_secret" "healthcare_agent_endpoint" {
  count        = 0 # Disabled due to access issues
  name         = "healthcare-agent-endpoint"
  value        = azurerm_cognitive_account.healthcare_agent.endpoint
  key_vault_id = var.key_vault_id
}

# Service principal role assignments
resource "azurerm_role_assignment" "service_principals" {
  for_each             = var.service_principal_ids
  scope                = azurerm_cognitive_account.healthcare_agent.id
  role_definition_name = "Cognitive Services User"
  principal_id         = each.value
  
  # Add lifecycle to prevent destroy and ignore changes
  lifecycle {
    ignore_changes = [scope, principal_id]
  }
}
