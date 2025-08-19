output "ai_hub_id" {
  description = "ID of the AI Hub"
  value       = azurerm_cognitive_account.ai_hub.id
}

output "ai_hub_endpoint" {
  description = "Endpoint of the AI Hub"
  value       = azurerm_cognitive_account.ai_hub.endpoint
}

output "container_registry_id" {
  description = "ID of the container registry"
  value       = azurerm_container_registry.hub_registry.id
}

output "container_registry_login_server" {
  description = "Login server for the container registry"
  value       = azurerm_container_registry.hub_registry.login_server
}
