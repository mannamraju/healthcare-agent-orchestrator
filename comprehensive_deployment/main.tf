provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Random string to ensure uniqueness
resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
}

locals {
  name_prefix  = "${var.environment_name}-${random_string.suffix.result}"
  ai_hub_name  = "cog-hub-${local.name_prefix}"
  storage_name = "st${var.environment_name}${random_string.suffix.result}"
  app_storage_name = "stapp${var.environment_name}${random_string.suffix.result}"
  keyvault_name = "kv-${local.name_prefix}"
}

# Virtual Network
module "network" {
  source              = "./tf_modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  name_prefix         = local.name_prefix
  address_space       = var.network_address_space
  subnets             = var.network_subnets
  enable_vpn_gateway  = var.enable_vpn_gateway
  tags                = var.tags
}

# Azure AI Services
module "ai_services" {
  source              = "./tf_modules/ai-services"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  name_prefix         = local.name_prefix
  subnet_id           = module.network.private_endpoints_subnet_id
  private_dns_zone_ids = module.network.private_dns_zone_ids
  create_private_endpoints = var.create_private_endpoints
  tags                = var.tags
}

# Azure AI Hub
module "ai_hub" {
  source               = "./tf_modules/ai-hub"
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  ai_hub_name          = local.ai_hub_name
  ai_service_id        = module.ai_services.ai_service_id
  container_registry_name = "coghub${var.environment_name}${random_string.suffix.result}registry"
  tags                 = var.tags
}

# Key Vault
module "key_vault" {
  source               = "./tf_modules/key-vault"
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  name                 = local.keyvault_name
  tenant_id            = data.azurerm_client_config.current.tenant_id
  subnet_id            = module.network.private_endpoints_subnet_id
  private_dns_zone_ids = module.network.private_dns_zone_ids
  create_private_endpoint = var.create_private_endpoints
  tags                 = var.tags
}

# Storage Accounts
module "storage" {
  source                = "./tf_modules/storage-account"
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  storage_account_name  = local.storage_name
  app_storage_name      = local.app_storage_name
  subnet_id             = module.network.private_endpoints_subnet_id
  private_dns_zone_ids  = module.network.private_dns_zone_ids
  create_private_endpoints = var.create_private_endpoints
  tags                  = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "appi-${local.name_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "ase-${local.name_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Windows"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

# Healthcare Agent App Service
module "healthcare_agent" {
  source                = "./tf_modules/app-service"
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  name_prefix           = local.name_prefix
  app_service_plan_id   = azurerm_service_plan.main.id
  subnet_id             = module.network.private_endpoints_subnet_id
  private_dns_zone_ids  = module.network.private_dns_zone_ids
  app_insights_key      = azurerm_application_insights.main.instrumentation_key
  storage_connection    = module.storage.primary_connection_string
  keyvault_url          = module.key_vault.vault_uri
  ai_endpoint           = module.ai_services.endpoint
  ai_key                = module.ai_services.api_key
  app_settings          = var.app_settings
  create_private_endpoint = var.create_private_endpoints
  tags                  = var.tags
}

# Bot Service Resources
module "bot_services" {
  source              = "./tf_modules/bot-service"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  name_prefix         = local.name_prefix
  tenant_id           = data.azurerm_client_config.current.tenant_id
  bot_names           = var.bot_names
  app_service_id      = module.healthcare_agent.app_service_id
  tags                = var.tags
}
