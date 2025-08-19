# Core infrastructure deployment for Healthcare Agent Orchestrator
# This is a separate Terraform configuration to avoid conflicts with the main deployment

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Use the core-infrastructure module for all base resources
module "core" {
  source = "../tf_modules/core-infrastructure"

  resource_group_name     = var.resource_group_name
  location                = var.location
  storage_account_name    = var.storage_account_name
  app_storage_account_name = var.app_storage_account_name
  vnet_name               = var.vnet_name
  vnet_address_space      = var.vnet_address_space
  subnet_name             = var.subnet_name
  subnet_prefix           = var.subnet_prefix
  key_vault_name          = var.key_vault_name
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azurerm_client_config.current.object_id
  tags                    = var.tags
}

# Output the core infrastructure values
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.core.resource_group_name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = module.core.resource_group_location
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.core.storage_account_name
}

output "app_storage_account_name" {
  description = "Name of the created app storage account"
  value       = module.core.app_storage_account_name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = module.core.vnet_id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = module.core.subnet_id
}

output "key_vault_id" {
  description = "ID of the created Key Vault"
  value       = module.core.key_vault_id
}

output "key_vault_uri" {
  description = "URI of the created Key Vault"
  value       = module.core.key_vault_uri
}
