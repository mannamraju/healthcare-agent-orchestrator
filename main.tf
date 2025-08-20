# Healthcare Agent Orchestrator - Main Terraform Configuration
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"  # Upgraded to v4.0+ for Azure ML native resource support
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.53.1"   # Keep the same version that was locked
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {}

# Data sources
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# Local values for naming and configuration
locals {
  # Load abbreviations for consistent naming
  abbreviations = jsondecode(file("${path.module}/infra/abbreviations.json"))

  # Generate unique suffix for resource names
  unique_suffix = substr(sha1("${data.azurerm_client_config.current.subscription_id}-${var.environment_name}"), 0, 3)
  
  # Role assignment control - set to false to skip creating role assignments that might already exist
  create_role_assignments = false
  
  # FHIR Service configuration
  clinical_notes_source = "blob" # Can be "blob", "fhir", or "fabric"
  should_deploy_fhir_service = local.clinical_notes_source == "fhir"

  # Resource names with friendly parameters
  resource_names = {
    managed_identity    = var.managed_identity_name != "" ? var.managed_identity_name : "${local.abbreviations.managedIdentityUserAssignedIdentities}${var.environment_name}-${local.unique_suffix}"
    app_service_plan    = var.app_service_plan_name != "" ? var.app_service_plan_name : "${local.abbreviations.webSitesAppServiceEnvironment}${var.environment_name}-${local.unique_suffix}"
    app_service         = var.app_service_name != "" ? var.app_service_name : "${local.abbreviations.webSitesAppService}${var.environment_name}-${local.unique_suffix}"
    ai_services         = var.ai_services_name != "" ? var.ai_services_name : "${local.abbreviations.cognitiveServicesAccounts}${var.environment_name}-${local.unique_suffix}"
    ai_hub              = var.ai_hub_name != "" ? var.ai_hub_name : "${local.abbreviations.cognitiveServicesAccounts}hub-${var.environment_name}-${local.unique_suffix}"
    storage_account     = var.storage_account_name != "" ? var.storage_account_name : replace(replace("${local.abbreviations.storageStorageAccounts}${var.environment_name}${local.unique_suffix}", "-", ""), "_", "")
    app_storage_account = var.app_storage_account_name != "" ? var.app_storage_account_name : replace(replace("${local.abbreviations.storageStorageAccounts}app${var.environment_name}${local.unique_suffix}", "-", ""), "_", "")
    key_vault           = var.key_vault_name != "" ? var.key_vault_name : "${local.abbreviations.keyVaultVaults}${var.environment_name}-${local.unique_suffix}"
  }

  # Agent configuration
  agent_configs = {
    default = yamldecode(file("${path.module}/src/scenarios/default/config/agents.yaml"))
  }

  all_agents = local.agent_configs[var.scenario]
  agents     = local.all_agents

  # Healthcare agents filtering
  healthcare_agents = [
    for agent in local.all_agents : agent
    if can(agent.healthcare_agent) && agent.healthcare_agent
  ]

  has_radiology_agent = contains([
    for agent in local.healthcare_agents : lower(agent.name)
  ], "radiology")
  
  # HLS model configuration 
  has_hls_model_endpoints = length(var.hls_model_endpoints) > 0 && lookup(var.hls_model_endpoints, "cxr_report_gen", "") != ""

  # Model configuration
  model_parts   = split(";", var.openai_model)
  model_name    = local.model_parts[0]
  model_version = local.model_parts[1]

  # Tags
  common_tags = merge(var.tags, {
    Environment = var.environment_name
    Project     = "healthcare-agent-orchestrator"
  })
}

# Use existing resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Managed Identities for each agent
module "managed_identities" {
  source = "./tf_modules/managed-identity"

  for_each = { for idx, agent in local.agents : agent.name => agent }

  name                = each.value.name
  location            = var.managed_identity_location != "" ? var.managed_identity_location : data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags
}

# Combine all managed identities into a map for usage elsewhere
locals {
  all_identities = { for name, identity in module.managed_identities : name => {
    id           = identity.id
    principal_id = identity.principal_id
    client_id    = identity.client_id
    name         = name
  } }
}

# AI Services
module "ai_services" {
  source = "./tf_modules/ai-services"

  ai_services_name    = local.resource_names.ai_services
  location            = "westus" # Fixed to West US for best GPT-4o support
  resource_group_name = data.azurerm_resource_group.main.name
  key_vault_name      = local.resource_names.key_vault
  key_vault_id        = module.key_vault.id
  tags                = local.common_tags
  
  # Model configuration from variables
  model_name          = local.model_name
  model_version       = local.model_version
  model_capacity      = var.openai_model_capacity
}

# Key Vault
module "key_vault" {
  source = "./tf_modules/key-vault"

  name                = local.resource_names.key_vault
  location            = var.key_vault_location != "" ? var.key_vault_location : data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags
  tenant_id           = data.azurerm_client_config.current.tenant_id

  user_principal_id   = var.my_principal_id
  user_principal_type = var.my_principal_type
  service_principal_ids = {
    for k, v in module.managed_identities : k => v.principal_id
  }
}

# OpenAI GPT Deployment
module "gpt_deployment" {
  source = "./tf_modules/gpt-deployment"
  count  = var.enable_openai ? 1 : 0

  resource_group_name = data.azurerm_resource_group.main.name
  ai_services_id      = module.ai_services.id
  model_name          = local.model_name
  model_version       = local.model_version
  model_capacity      = var.openai_model_capacity
  model_sku           = var.openai_model_sku
}

# AI Hub
module "ai_hub" {
  source = "./tf_modules/ai-hub"

  ai_hub_name          = local.resource_names.ai_hub
  ai_project_name      = "cog-ai-prj-${var.environment_name}-${local.unique_suffix}"
  storage_account_name = local.resource_names.storage_account
  location             = "global" # Explicitly set to global to match existing resource
  resource_group_name  = data.azurerm_resource_group.main.name
  subscription_id      = data.azurerm_client_config.current.subscription_id
  ai_services_name     = local.resource_names.ai_services
  key_vault_name       = local.resource_names.key_vault
  key_vault_id         = module.key_vault.id
  key_vault_uri        = module.key_vault.uri
  tags                 = local.common_tags
  shared_access_key_enabled = var.storage_shared_access_key_enabled
  service_principal_ids = {
    for k, v in module.managed_identities : k => v.principal_id
  }
  create_role_assignments = local.create_role_assignments
}

# HLS Models - Only deploy if no model endpoints are provided
module "hls_models" {
  source = "./tf_modules/hls-models"
  count  = local.has_hls_model_endpoints ? 0 : 1

  location            = var.hls_deployment_location != "" ? var.hls_deployment_location : data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  workspace_name      = var.existing_ai_workspace_name != "" ? var.existing_ai_workspace_name : module.ai_hub.ai_hub_name
  instance_type       = var.instance_type
  include_radiology_models = local.has_radiology_agent
}

# App Storage Account - Bypass module entirely and just create the values we need
locals {
  app_storage_name = local.resource_names.app_storage_account
  app_storage_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.main.name}/providers/Microsoft.Storage/storageAccounts/${local.app_storage_name}"
  app_storage_blob_endpoint = "https://${local.app_storage_name}.blob.core.windows.net/"
  
  # These are the names of containers we assume exist in the storage account
  app_storage_containers = {
    chat_artifacts = "chat-artifacts"
    chat_sessions = "chat-sessions"
    patient_data = "patient-data"
  }
}

# Use role assignment directly without going through module
resource "azurerm_role_assignment" "app_storage_user" {
  count = var.my_principal_id != "" ? 1 : 0

  scope                = local.app_storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.my_principal_id
  principal_type       = var.my_principal_type
  
  # Add lifecycle block to prevent errors if already exists
  lifecycle {
    ignore_changes = [scope, principal_id]
  }
}

# Use count=0 to disable since the assignment already exists
resource "azurerm_role_assignment" "app_storage_msi" {
  count                = 0
  scope                = local.app_storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = values(module.managed_identities)[0].principal_id
  principal_type       = "ServicePrincipal"
  
  # Add lifecycle block to ignore errors if the role assignment already exists
  lifecycle {
    ignore_changes = [scope, principal_id]
  }
}

# App Service
module "app_service" {
  source = "./tf_modules/app-service"

  name                = local.resource_names.app_service
  location            = var.app_service_location != "" ? var.app_service_location : data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags

  app_service_plan_id        = module.app_service_plan.id
  key_vault_id               = module.key_vault.id
  key_vault_uri              = module.key_vault.vault_uri
  app_blob_storage_endpoint  = local.app_storage_blob_endpoint
  ai_project_name            = module.ai_hub.ai_hub_name
  ai_project_connection_string = "azureml://subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.CognitiveServices/accounts/${module.ai_hub.ai_hub_name}"

  managed_identities = local.all_identities
  openai_endpoint    = module.ai_services.endpoint
  
  # Optionally use separate reasoning model endpoint
  openai_endpoint_reasoning_model = var.reasoning_model_endpoint != "" ? var.reasoning_model_endpoint : module.ai_services.endpoint
  
  deployment_name       = var.enable_openai ? var.openai_model : ""
  deployment_name_reasoning_model = var.reasoning_model_deployment_name
  auth_client_id        = var.auth_client_id
  graph_rag_subscription_key = var.graph_rag_subscription_key
  
  # HLS Model endpoints
  model_endpoints       = local.has_hls_model_endpoints ? var.hls_model_endpoints : (var.enable_openai && length(module.hls_models) > 0 ? module.hls_models[0].model_endpoints : {})
  
  # Scenario configuration  
  scenario = var.scenario
  
  # Application Insights integration
  application_insights_connection_string = module.app_insights.connection_string
  
  # Network integration
  subnet_id = module.virtual_network.app_service_subnet_id
  additional_allowed_ips = []
  additional_allowed_tenant_ids = []
  
  # Clinical notes settings
  clinical_notes_source = local.clinical_notes_source
  fhir_service_endpoint = local.should_deploy_fhir_service ? module.fhir_service[0].endpoint : ""
  fabric_user_data_function_endpoint = ""

  depends_on = [
    module.app_insights,
    module.virtual_network
  ]
}

# Virtual Network 
module "virtual_network" {
  source = "./tf_modules/network-module"

  vnet_name          = var.vnet_name != "" ? var.vnet_name : "vnet-${var.environment_name}-${local.unique_suffix}"
  location           = var.app_service_location != "" ? var.app_service_location : data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  vnet_address_prefixes = [var.vnet_address_space]
  app_service_subnet_prefix = var.subnet_prefix
  tags               = local.common_tags
}

# Application Insights
module "app_insights" {
  source = "./tf_modules/application-insights"

  app_insights_name    = "appi-${var.environment_name}-${local.unique_suffix}"
  location            = var.app_service_location != "" ? var.app_service_location : data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags
  
  # Access control
  service_principal_ids = [for k, v in local.all_identities : v.principal_id]
  user_principal_id     = var.my_principal_id
}

# App Service Plan
module "app_service_plan" {
  source = "./tf_modules/app-service-plan"

  name                = local.resource_names.app_service_plan
  location            = var.app_service_location != "" ? var.app_service_location : data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags
  sku_name            = var.app_service_plan_sku != "" ? var.app_service_plan_sku : "S1"  # Use S1 as default
  
  # Note: zone_redundancy parameter removed as it's not supported by the module
}

# FHIR Service
module "fhir_service" {
  source              = "./tf_modules/fhir-service"
  count               = local.should_deploy_fhir_service ? 1 : 0
  
  workspace_name      = replace("ahds${var.environment_name}${local.unique_suffix}", "-", "")
  fhir_service_name   = replace("fhir${var.environment_name}${local.unique_suffix}", "-", "")
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  data_contributors   = [{
    id   = coalesce(var.my_principal_id, data.azurerm_client_config.current.object_id)
    type = var.my_principal_type
  }]
  data_readers       = [{
    id   = values(local.all_identities)[0].principal_id
    type = "ServicePrincipal"
  }]
  tags               = local.common_tags
}

# Healthcare Agent Service - only deploy if there are healthcare agents
module "healthcare_agent" {
  source = "./tf_modules/healthcare-agent-module"
  count  = length(local.healthcare_agents) > 0 ? 1 : 0

  healthcare_agent_name = "hao-agent-${var.environment_name}"
  environment_name      = var.environment_name
  location              = var.healthcare_agent_service_location != "" ? var.healthcare_agent_service_location : data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  tags                  = local.common_tags

  key_vault_id          = module.key_vault.id
  
  # Healthcare bots configuration - convert agents to healthcare_bots format
  healthcare_bots = {
    for agent in local.healthcare_agents : agent.name => {
      name = agent.name
    }
  }
  
  # Role assignments
  create_role_assignments = local.create_role_assignments
  user_principal_id       = var.my_principal_id
  ai_hub_principal_id     = module.ai_hub.ai_hub_principal_id
  openai_principal_id     = module.ai_services.principal_id
  
  # Service principals for agents
  service_principal_ids = {
    for k, v in module.managed_identities : k => v.principal_id
    if contains([for agent in local.healthcare_agents : agent.name], k)
  }
}

# Bot Services
module "bot_services" {
  source = "./tf_modules/bot-service"

  location            = "westus"  # Bot Service requires specific regions: global, westeurope, westus, centralindia
  resource_group_name = data.azurerm_resource_group.main.name
  app_backend_hostname = module.app_service.hostname
  tenant_id           = data.azurerm_client_config.current.tenant_id
  unique_suffix       = local.unique_suffix
  tags                = local.common_tags
  
  bots = {
    for agent in local.agents : agent.name => {
      client_id = module.managed_identities[agent.name].client_id
      id        = module.managed_identities[agent.name].id
      name      = agent.name
    }
  }
}
