# Main Storage Account
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  blob_properties {
    change_feed_enabled = true
    versioning_enabled  = true
    
    container_delete_retention_policy {
      days = 7
    }
  }
  
  tags = var.tags
}

# App Storage Account
resource "azurerm_storage_account" "app" {
  name                     = var.app_storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  tags = var.tags
}

# Event Grid System Topic for Storage Account
resource "azurerm_eventgrid_system_topic" "storage" {
  name                   = "${var.storage_account_name}-${random_uuid.storage_suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  source_arm_resource_id = azurerm_storage_account.main.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
  tags                   = var.tags
}

resource "azurerm_eventgrid_system_topic" "app_storage" {
  name                   = "${var.app_storage_name}-${random_uuid.app_storage_suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  source_arm_resource_id = azurerm_storage_account.app.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
  tags                   = var.tags
}

# Container for data
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Private Endpoint for Storage Blob
resource "azurerm_private_endpoint" "storage_blob" {
  count = var.create_private_endpoints ? 1 : 0

  name                = "${var.storage_account_name}-pe-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-blob-connection"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "storage-blob-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.blob.core.windows.net"]]
  }

  tags = var.tags
}

# Random UUIDs for Event Grid Topics
resource "random_uuid" "storage_suffix" {}
resource "random_uuid" "app_storage_suffix" {}
