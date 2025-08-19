output "app_service_id" {
  description = "ID of the App Service"
  value       = azurerm_windows_web_app.main.id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_windows_web_app.main.name
}

output "default_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_windows_web_app.main.default_hostname
}

output "principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = azurerm_windows_web_app.main.identity[0].principal_id
}
