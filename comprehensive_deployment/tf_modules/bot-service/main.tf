# Generate random string for bot service suffix
resource "random_string" "bot_suffix" {
  length  = 12
  special = false
  upper   = false
}

# Create managed identities for bots
resource "azurerm_user_assigned_identity" "bot_identities" {
  for_each = toset(var.bot_names)

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Create Azure Bot Services
resource "azurerm_bot_service_azure_bot" "bots" {
  for_each = toset(var.bot_names)

  name                     = "${each.key}-${random_string.bot_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = "global"
  microsoft_app_id         = azurerm_user_assigned_identity.bot_identities[each.key].client_id
  sku                      = "S1"
  endpoint                 = "https://healthbot.bot.healthagent.example"
  # Removed empty App Insights fields that were causing errors
  
  tags = var.tags
}

# Role assignments for bots to access app service
resource "azurerm_role_assignment" "bot_app_service_contributor" {
  for_each = azurerm_user_assigned_identity.bot_identities

  scope                = var.app_service_id
  role_definition_name = "Contributor"
  principal_id         = each.value.principal_id
}
