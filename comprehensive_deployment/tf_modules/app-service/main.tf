# Healthcare Agent App Service
resource "azurerm_windows_web_app" "main" {
  name                = "app-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.app_service_plan_id

  https_only = true

  site_config {
    always_on                = true
    minimum_tls_version      = "1.2"
    ftps_state               = "Disabled"
    health_check_path        = "/health"
    health_check_eviction_time_in_min = 10  # Added required field
    websockets_enabled       = true
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge({
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = var.app_insights_key
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"
    "AzureWebJobsStorage"                   = var.storage_connection
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"       = "true"
    "KeyVaultURL"                           = var.keyvault_url
    "OpenAIEndpoint"                         = var.ai_endpoint
    "OpenAIKey"                              = var.ai_key
    "WEBSITE_HEALTHCHECK_MAXPINGFAILURES"   = "10"
    "WEBSITE_NODE_DEFAULT_VERSION"          = "~16"
  }, var.app_settings)

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  tags = var.tags
}

# Private Endpoint for App Service
resource "azurerm_private_endpoint" "app_service" {
  count = var.create_private_endpoint ? 1 : 0

  name                = "${azurerm_windows_web_app.main.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${azurerm_windows_web_app.main.name}-connection"
    private_connection_resource_id = azurerm_windows_web_app.main.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "app-service-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.azurewebsites.net"]]
  }

  tags = var.tags
}
