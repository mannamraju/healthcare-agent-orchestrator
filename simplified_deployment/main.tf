terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.53.1"
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

# Resource Group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# AI Services for OpenAI
resource "azurerm_cognitive_account" "ai_services" {
  name                = "cog-${var.environment_name}-${local.unique_suffix}"
  location            = "westus"
  resource_group_name = data.azurerm_resource_group.main.name
  kind                = "OpenAI"
  sku_name            = "S0"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

# GPT-4o Deployment
resource "azurerm_cognitive_deployment" "gpt4o" {
  name                 = "gpt4o"
  cognitive_account_id = azurerm_cognitive_account.ai_services.id
  model {
    name    = "gpt-4o"
    version = "2024-08-06"
    format  = "OpenAI"
  }
  sku {
    name     = "Standard"
    capacity = var.openai_model_capacity
  }
}

# Network resources
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment_name}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "app_service" {
  name                 = "app-service-subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.environment_name}-${local.unique_suffix}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  application_type    = "web"
}

# FHIR Service
resource "azurerm_healthcare_workspace" "main" {
  count               = var.clinical_notes_source == "fhir" ? 1 : 0
  name                = "ahds-${var.environment_name}-${local.unique_suffix}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
}

resource "azurerm_healthcare_fhir_service" "main" {
  count                     = var.clinical_notes_source == "fhir" ? 1 : 0
  name                      = "fhir-${var.environment_name}-${local.unique_suffix}"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  workspace_id              = azurerm_healthcare_workspace.main[0].id
  kind                      = "fhir-R4"
  public_network_access_enabled = true
  
  authentication {
    authority = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    audience  = "https://fhir-${var.environment_name}-${local.unique_suffix}.azurehealthcareapis.com"
    smart_proxy_enabled = false
  }
}

# Local values
locals {
  unique_suffix = substr(sha1("${data.azurerm_client_config.current.subscription_id}-${var.environment_name}"), 0, 3)
}

output "openai_endpoint" {
  description = "The endpoint of the OpenAI service"
  value       = azurerm_cognitive_account.ai_services.endpoint
}

output "openai_deployment_name" {
  description = "The name of the OpenAI deployment"
  value       = azurerm_cognitive_deployment.gpt4o.name
}

output "application_insights_connection_string" {
  description = "The connection string of the Application Insights instance"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "fhir_service_endpoint" {
  description = "The endpoint of the FHIR service"
  value       = var.clinical_notes_source == "fhir" ? azurerm_healthcare_fhir_service.main[0].authentication[0].audience : "Not deployed"
}

output "app_service_subnet_id" {
  description = "The ID of the App Service subnet"
  value       = azurerm_subnet.app_service.id
}
