# Healthcare Agent Orchestrator - Terraform Outputs
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# AI Services outputs
output "ai_services_endpoint" {
  description = "Endpoint URL of the Azure AI Services account"
  value       = module.ai_services.endpoint
}

output "ai_services_id" {
  description = "Resource ID of the Azure AI Services account"
  value       = module.ai_services.id
}

# AI Hub outputs
output "ai_hub_name" {
  description = "Name of the Azure AI Hub account"
  value       = module.ai_hub.ai_hub_name
}

output "ai_hub_endpoint" {
  description = "Endpoint URL of the Azure AI Hub account"
  value       = module.ai_hub.ai_hub_endpoint
}

# App Service outputs
output "app_service_url" {
  description = "URL of the deployed App Service"
  value       = module.app_service.default_site_hostname
}

output "app_service_name" {
  description = "Name of the deployed App Service"
  value       = module.app_service.name
}

# Bot Service outputs
output "bot_services" {
  description = "Information about deployed bot services"
  value       = module.bot_services.bot_services
}

# Healthcare Agent outputs
output "healthcare_agent_endpoints" {
  description = "Endpoints for the Healthcare Agent services"
  value       = length(module.healthcare_agent) > 0 ? module.healthcare_agent[0].healthcareAgentServiceEndpoints : []
}

# Key Vault outputs
output "key_vault_uri" {
  description = "URI of the deployed Key Vault"
  value       = module.key_vault.uri
}

output "key_vault_name" {
  description = "Name of the deployed Key Vault"
  value       = module.key_vault.name
}

# Application Insights outputs
output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.app_insights.connection_string
  sensitive   = true
}

# Storage account outputs
output "storage_account_name" {
  description = "Name of the deployed Storage Account"
  value       = module.ai_hub.storage_account_name
}

output "storage_account_primary_endpoint" {
  description = "Primary endpoint of the deployed Storage Account"
  value       = module.ai_hub.storage_account_primary_endpoint
}

# GPU model deployment outputs
output "model_endpoints" {
  description = "Endpoints for the deployed models"
  value       = local.has_hls_model_endpoints ? var.hls_model_endpoints : (length(module.hls_models) > 0 ? module.hls_models[0].model_endpoints : {})
}

# FHIR service outputs
output "fhir_service_endpoint" {
  description = "Endpoint for the FHIR service"
  value       = local.should_deploy_fhir_service ? module.fhir_service[0].endpoint : ""
}
