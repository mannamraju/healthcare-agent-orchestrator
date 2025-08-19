# Outputs for AI Hub Module

output "ai_hub_id" {
  description = "ID of the AI Hub"
  value       = data.azurerm_cognitive_account.ai_hub.id
}

output "ai_hub_name" {
  description = "Name of the AI Hub"
  value       = data.azurerm_cognitive_account.ai_hub.name
}

output "ai_hub_endpoint" {
  description = "Endpoint URL for the AI Hub"
  value       = data.azurerm_cognitive_account.ai_hub.endpoint
}

output "ai_project_name" {
  description = "Name of the AI Project (from configuration)"
  value       = var.ai_project_name
}

output "principal_id" {
  description = "Principal ID of the managed identity"
  value       = try(data.azurerm_cognitive_account.ai_hub.identity[0].principal_id, "")
}

output "storage_account_id" {
  description = "ID of the storage account for AI Hub"
  value       = var.create_storage ? azurerm_storage_account.ai_hub[0].id : null
}

output "storage_account_name" {
  description = "Name of the storage account for AI Hub"
  value       = var.create_storage ? azurerm_storage_account.ai_hub[0].name : null
}
