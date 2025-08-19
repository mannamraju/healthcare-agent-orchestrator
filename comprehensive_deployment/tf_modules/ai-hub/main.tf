# Container Registry for AI Hub
resource "azurerm_container_registry" "hub_registry" {
  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
  tags                = var.tags
}

# AI Hub
resource "azurerm_cognitive_account" "ai_hub" {
  name                = var.ai_hub_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "CognitiveServices"  # Changed from "AIHub" to supported kind
  sku_name            = "S0"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Role assignment for AI Hub to access AI Services
resource "azurerm_role_assignment" "ai_hub_to_services" {
  scope                = var.ai_service_id
  role_definition_name = "Cognitive Services User"
  principal_id         = azurerm_cognitive_account.ai_hub.identity[0].principal_id
}

# Role assignment for AI Hub to access Container Registry
resource "azurerm_role_assignment" "ai_hub_to_registry" {
  scope                = azurerm_container_registry.hub_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_cognitive_account.ai_hub.identity[0].principal_id
}
