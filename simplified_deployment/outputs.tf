# Output values for simplified deployment

output "resource_group_name" {
  description = "Name of the resource group where resources are deployed"
  value       = data.azurerm_resource_group.main.name
}

output "openai_endpoint" {
  description = "The endpoint of the OpenAI service"
  value       = azurerm_cognitive_account.ai_services.endpoint
}

output "openai_api_key" {
  description = "The API key for the OpenAI service"
  value       = azurerm_cognitive_account.ai_services.primary_access_key
  sensitive   = true
}

output "openai_deployment_name" {
  description = "The name of the OpenAI model deployment"
  value       = azurerm_cognitive_deployment.gpt4o.name
}

output "application_insights_connection_string" {
  description = "The connection string of Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "fhir_service_endpoint" {
  description = "The endpoint of the FHIR service (if deployed)"
  value       = var.clinical_notes_source == "fhir" ? "https://${azurerm_healthcare_fhir_service.main[0].name}.azurehealthcareapis.com" : "Not deployed"
}

output "virtual_network_name" {
  description = "The name of the created virtual network"
  value       = azurerm_virtual_network.main.name
}

output "app_service_subnet_id" {
  description = "The ID of the App Service subnet"
  value       = azurerm_subnet.app_service.id
}

output "deployment_summary" {
  description = "Summary of the deployed environment"
  value       = "Healthcare Agent simplified deployment completed for environment: ${var.environment_name}"
}
