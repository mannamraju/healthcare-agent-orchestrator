# Core infrastructure deployment script for Healthcare Agent Orchestrator
# This script deploys only the core infrastructure

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
}

# Load the azurerm provider
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
  subscription_id = "69642945-f464-4724-ba83-205eecbe5937"
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Common tags for all resources
locals {
  common_tags = {
    Environment = "Development"
    Project     = "Healthcare Agent Orchestrator"
    Deployment  = "US West Core Infrastructure"
    ManagedBy   = "Terraform"
  }
}

# Use the core-infrastructure module for all base resources
module "core" {
  source = "../tf_modules/core-infrastructure"

  resource_group_name     = "hao_0816"
  location                = "westus"
  storage_account_name    = "haowest0816sa"
  app_storage_account_name = "appwest0816sa"
  vnet_name               = "vnet-hao-0816-west"
  vnet_address_space      = "10.0.0.0/16"
  subnet_name             = "default"
  subnet_prefix           = "10.0.0.0/24"
  key_vault_name          = "kv-westus-hao0816"
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azurerm_client_config.current.object_id
  tags                    = local.common_tags
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
