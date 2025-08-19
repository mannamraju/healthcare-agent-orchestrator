# Outputs for AI Services deployment

output "id" {
  description = "ID of the OpenAI service"
  value       = module.ai_services.id
}

output "name" {
  description = "Name of the OpenAI service"
  value       = module.ai_services.name
}

output "endpoint" {
  description = "Endpoint URL for the OpenAI service"
  value       = module.ai_services.endpoint
}

output "model_deployment_id" {
  description = "ID of the model deployment"
  value       = module.ai_services.model_deployment_id
}

output "model_deployment_name" {
  description = "Name of the model deployment"
  value       = module.ai_services.model_deployment_name
}

output "principal_id" {
  description = "Principal ID of the OpenAI managed identity"
  value       = module.ai_services.principal_id
}
