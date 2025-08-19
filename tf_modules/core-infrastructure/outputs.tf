# Outputs for core infrastructure module

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.core.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.core.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.core.location
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.core.name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.core.id
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.core.primary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.core.primary_connection_string
  sensitive   = true
}

output "app_storage_account_name" {
  description = "Name of the created app storage account"
  value       = azurerm_storage_account.app.name
}

output "app_storage_account_id" {
  description = "ID of the created app storage account"
  value       = azurerm_storage_account.app.id
}

output "app_storage_account_primary_access_key" {
  description = "Primary access key for the app storage account"
  value       = azurerm_storage_account.app.primary_access_key
  sensitive   = true
}

output "app_storage_account_primary_connection_string" {
  description = "Primary connection string for the app storage account"
  value       = azurerm_storage_account.app.primary_connection_string
  sensitive   = true
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.core.id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.core.name
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = azurerm_subnet.default.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = azurerm_subnet.default.name
}

output "key_vault_id" {
  description = "ID of the created Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the created Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}
