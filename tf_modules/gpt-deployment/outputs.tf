output "id" {
  description = "The ID of the GPT deployment"
  value       = length(azurerm_cognitive_deployment.gpt_model) > 0 ? azurerm_cognitive_deployment.gpt_model[0].id : null
}

output "model_name" {
  description = "The name of the GPT model"
  value       = var.model_name
}

output "model_version" {
  description = "The version of the GPT model"
  value       = var.model_version
}

output "model_capacity" {
  description = "The capacity of the GPT model"
  value       = var.model_capacity
}
