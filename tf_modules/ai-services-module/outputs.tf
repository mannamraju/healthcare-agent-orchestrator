# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# Outputs for AI Services Module

output "id" {
  description = "ID of the OpenAI service"
  value       = azurerm_cognitive_account.openai.id
}

output "name" {
  description = "Name of the OpenAI service"
  value       = azurerm_cognitive_account.openai.name
}

output "endpoint" {
  description = "Endpoint URL for the OpenAI service"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "primary_access_key" {
  description = "Primary access key for the OpenAI service"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

output "model_deployment_id" {
  description = "ID of the model deployment"
  value       = azurerm_cognitive_deployment.gpt.id
}

output "model_deployment_name" {
  description = "Name of the model deployment"
  value       = azurerm_cognitive_deployment.gpt.name
}

output "principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_cognitive_account.openai.identity[0].principal_id
}

output "openai_account_id" {
  description = "ID of the Azure OpenAI Cognitive Account"
  value       = azurerm_cognitive_account.openai.id
}