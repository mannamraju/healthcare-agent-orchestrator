output "primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "app_storage_primary_access_key" {
  description = "Primary access key for the app storage account"
  value       = azurerm_storage_account.app.primary_access_key
  sensitive   = true
}

output "app_storage_primary_connection_string" {
  description = "Primary connection string for the app storage account"
  value       = azurerm_storage_account.app.primary_connection_string
  sensitive   = true
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "app_storage_name" {
  description = "Name of the app storage account"
  value       = azurerm_storage_account.app.name
}

output "container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.data.name
}
