# Variables for core infrastructure module

# Subscription and resource group
variable "subscription_id" {
  description = "Azure Subscription ID where resources will be deployed"
  type        = string
  default     = "69642945-f464-4724-ba83-205eecbe5937"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "hao_0816"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "westus"
}

# Storage accounts
variable "storage_account_name" {
  description = "Name of the primary storage account"
  type        = string
  default     = "haowest0816sa"
}

variable "app_storage_account_name" {
  description = "Name of the app storage account"
  type        = string
  default     = "appwest0816sa"
}

# Networking
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-hao-0816-west"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Name of the default subnet"
  type        = string
  default     = "default"
}

variable "subnet_prefix" {
  description = "CIDR prefix for the default subnet"
  type        = string
  default     = "10.0.0.0/24"
}

# Key Vault
variable "key_vault_name" {
  description = "Name of the key vault"
  type        = string
  default     = "kv-westus-hao0816"
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "Healthcare Agent Orchestrator"
    Deployment  = "US West Core Infrastructure"
    ManagedBy   = "Terraform"
    CreatedDate = "2025-08-16"
  }
}
