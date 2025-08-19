# AI Services for OpenAI
resource "azurerm_cognitive_account" "ai_services" {
  name                = "cog-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# AI Project
resource "azurerm_cognitive_account" "ai_project" {
  name                = "cog-ai-prj-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "CognitiveServices"  # Changed from "AIServices" to supported kind
  sku_name            = "S0"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# OpenAI Model Deployments
resource "azurerm_cognitive_deployment" "models" {
  for_each = { for deployment in var.ai_model_deployments : deployment.name => deployment }

  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.ai_services.id
  
  model {
    name    = each.value.model
    version = each.value.version
    format  = "OpenAI"
  }
  
  sku {
    name     = "Standard"
    capacity = each.value.capacity
  }
}

# Private Endpoint for Cognitive Services
resource "azurerm_private_endpoint" "ai_services" {
  count = var.create_private_endpoints ? 1 : 0

  name                = "${azurerm_cognitive_account.ai_services.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${azurerm_cognitive_account.ai_services.name}-connection"
    private_connection_resource_id = azurerm_cognitive_account.ai_services.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "cognitive-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.cognitiveservices.azure.com"]]
  }

  tags = var.tags
}
