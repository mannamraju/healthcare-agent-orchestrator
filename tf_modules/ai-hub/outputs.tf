## Outputs for AI Hub deployment (native azurerm resources)

locals {
  aml_host = "${var.location}.api.azureml.ms"
}

output "ai_hub_id" {
  description = "ID of the AI Hub"
  value       = azurerm_ai_foundry.ai_hub.id
}

output "ai_hub_name" {
  description = "Name of the AI Hub"
  value       = azurerm_ai_foundry.ai_hub.name
}

output "ai_hub_endpoint" {
  description = "Endpoint host for the Azure ML discovery service"
  value       = local.aml_host
}

output "ai_project_name" {
  description = "Name of the AI Project"
  value       = var.ai_project_name
}

output "ai_project_id" {
  description = "Resource ID of the AI Project (ML workspace kind=Project)"
  value       = azurerm_ai_foundry_project.ai_project.id
}

output "ai_project_discovery_url" {
  description = "Discovery URL for the AI Project"
  value       = "azureml://${local.aml_host}/subscriptions/${local.subscription_id_from_hub}/resourceGroups/${var.resource_group_name}/providers/Microsoft.MachineLearningServices/workspaces/${var.ai_project_name}"
}

output "ai_project_connection_string" {
  description = "AI Project connection string to match Bicep output"
  value       = "${local.aml_host};${local.subscription_id_from_hub};${var.resource_group_name};${var.ai_project_name}"
}

output "ai_hub_principal_id" {
  description = "Principal ID of the AI Hub managed identity"
  value       = azurerm_ai_foundry.ai_hub.identity[0].principal_id
}
