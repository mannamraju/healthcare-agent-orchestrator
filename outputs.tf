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

# AI Project outputs
output "ai_project_connection_string" {
  description = "Connection string for the Azure AI Project (used by the app)"
  value       = module.ai_hub.ai_project_connection_string
}

output "ai_project_discovery_url" {
  description = "Discovery URL for the Azure AI Project"
  value       = module.ai_hub.ai_project_discovery_url
}

# App Service outputs
output "app_service_url" {
  description = "URL of the deployed App Service"
  value       = module.app_service.hostname
}

output "app_service_name" {
  description = "Name of the deployed App Service"
  value       = module.app_service.name
}

# Bot Service outputs
output "bot_services" {
  description = "Information about deployed bot services"
  value = {
    ids = module.bot_services.bot_ids
    names = module.bot_services.bot_names
    endpoints = module.bot_services.bot_endpoints
  }
}

output "bot_id_by_name" {
  description = "Map of Bot Service name to its client/application ID"
  value       = { for k in keys(module.bot_services.bot_names) : module.bot_services.bot_names[k] => module.bot_services.bot_ids[k] }
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

output "key_vault_id" {
  description = "Resource ID of the deployed Key Vault"
  value       = module.key_vault.id
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
  # value       = local.app_storage_name
  value       = module.app_storage.name
}

output "storage_account_primary_endpoint" {
  description = "Primary endpoint of the deployed Storage Account"
  # value       = local.app_storage_blob_endpoint
  value       = module.app_storage.primary_blob_endpoint
}

output "storage_account_id" {
  description = "Resource ID of the deployed Storage Account"
  value       = module.app_storage.id
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

# Virtual Network outputs
output "vnet_id" {
  description = "ID of the deployed Virtual Network"
  value       = module.virtual_network.vnet_id
}

output "vnet_name" {
  description = "Name of the deployed Virtual Network"
  value       = module.virtual_network.vnet_name
}

output "app_service_subnet_id" {
  description = "ID of the subnet used for App Service integration"
  value       = module.virtual_network.app_service_subnet_id
}

# Azure OpenAI endpoint aliases (for parity with app variables and Bicep outputs)
output "azure_openai_api_endpoint" {
  description = "Alias of the Azure OpenAI endpoint (same as ai_services_endpoint)"
  value       = module.ai_services.endpoint
}

output "azure_openai_endpoint" {
  description = "Alias of the Azure OpenAI endpoint for compatibility"
  value       = module.ai_services.endpoint
}

# Model inputs/derived values for scripts (.env synthesis)
output "openai_model" {
  description = "The combined OpenAI model string (name;version)"
  value       = var.openai_model
}

output "openai_deployment_name" {
  description = "The OpenAI deployment name derived from the model string"
  value       = split(";", var.openai_model)[0]
}

output "reasoning_model_deployment_name" {
  description = "The reasoning model deployment name (fallbacks to openai_deployment_name if not set)"
  value       = var.reasoning_model_deployment_name != "" ? var.reasoning_model_deployment_name : split(";", var.openai_model)[0]
}

output "resource_group_name" {
  description = "The name of the resource group used for this deployment"
  value       = azurerm_resource_group.main.name
}

# Convenience/alias outputs for azd env and scripts (match expected variable names)
output "APP_SERVICE_URL" {
  description = "App Service URL with https scheme (used by prepackage build to set REACT_APP_API_BASE_URL)"
  value       = "https://${module.app_service.hostname}"
}

output "AZURE_BOTS" {
  description = "Array of bots with name and botId, used by generateTeamsApp scripts"
  value = [
    for k, mi in module.managed_identities : {
      # Bot Service resource name pattern: <agentName>-<unique_suffix>
      name  = "${k}-${local.unique_suffix}"
      # Use the managed identity client (application) ID
      botId = mi.client_id
    }
  ]
}

output "FHIR_SERVICE_ENDPOINT" {
  description = "FHIR service endpoint alias in uppercase for scripts"
  value       = local.should_deploy_fhir_service ? module.fhir_service[0].endpoint : ""
}

output "APP_STORAGE_ACCOUNT_NAME" {
  description = "Storage account name alias used by uploadPatientData.sh"
  value       = module.app_storage.name
}

# Required by azd appservice host for deploy target
output "AZURE_RESOURCE_GROUP_NAME" {
  description = "Resource group containing the App Service"
  value       = azurerm_resource_group.main.name
}

# Compatibility alias:
output "AZURE_RESOURCE_GROUP" {
  description = "Compatibility alias for resource group name"
  value       = azurerm_resource_group.main.name
}