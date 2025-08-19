output "endpoint" {
  description = "The endpoint of the OpenAI service"
  value       = azurerm_cognitive_account.ai_services.endpoint
}

output "api_key" {
  description = "The API key for the OpenAI service"
  value       = azurerm_cognitive_account.ai_services.primary_access_key
  sensitive   = true
}

output "ai_service_id" {
  description = "The ID of the AI Services account"
  value       = azurerm_cognitive_account.ai_services.id
}

output "ai_project_id" {
  description = "The ID of the AI Project account"
  value       = azurerm_cognitive_account.ai_project.id
}

output "model_deployment_ids" {
  description = "Map of model deployment names to IDs"
  value       = { for name, deployment in azurerm_cognitive_deployment.models : name => deployment.id }
}
