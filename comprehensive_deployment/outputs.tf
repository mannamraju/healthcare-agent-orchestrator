output "resource_group_name" {
  description = "Name of the resource group where resources are deployed"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.network.vnet_name
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = module.healthcare_agent.app_service_name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = module.healthcare_agent.default_hostname
}

output "ai_service_endpoint" {
  description = "Endpoint of the AI service"
  value       = module.ai_services.endpoint
}

output "ai_hub_name" {
  description = "Name of the AI Hub"
  value       = local.ai_hub_name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.key_vault_name
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = module.storage.storage_account_name
}

output "app_storage_name" {
  description = "Name of the App Storage Account"
  value       = module.storage.app_storage_name
}

output "application_insights_name" {
  description = "Name of Application Insights"
  value       = azurerm_application_insights.main.name
}

output "bot_services" {
  description = "Map of bot names to their service resources"
  value       = module.bot_services.bot_services
}

output "managed_identities" {
  description = "Map of bot names to their managed identities"
  value       = module.bot_services.bot_identities
}
