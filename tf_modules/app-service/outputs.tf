output "id" {
  description = "The ID of the App Service"
  value       = azurerm_linux_web_app.main.id
}

output "name" {
  description = "The name of the App Service"
  value       = azurerm_linux_web_app.main.name
}

output "hostname" {
  description = "The hostname of the App Service"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "principal_id" {
  description = "The principal ID of the system assigned identity of the App Service"
  value       = length(azurerm_linux_web_app.main.identity) > 0 ? azurerm_linux_web_app.main.identity[0].principal_id : ""
}

output "bot_ids" {
  description = "The bot IDs defined in the App Service"
  value       = local.bot_ids
}
