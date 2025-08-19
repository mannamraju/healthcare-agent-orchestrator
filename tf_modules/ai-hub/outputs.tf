# Outputs for AI Hub deployment

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
  description = "Name of the AI Project"
  value       = var.ai_project_name
}

output "ai_hub_principal_id" {
  description = "Principal ID of the AI Hub managed identity"
  value       = data.azurerm_cognitive_account.ai_hub.identity[0].principal_id
}
