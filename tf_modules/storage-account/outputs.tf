output "id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.main.name
}


output "primary_blob_endpoint" {
  description = "The primary blob endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "blob_endpoint" {
  description = "The blob endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}
