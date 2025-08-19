# Variables for AI Hub Module

# Required variables
variable "resource_group_name" {
  description = "Name of the resource group where resources will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for AI services"
  type        = string
}

variable "ai_hub_name" {
  description = "Name of the Azure AI Hub"
  type        = string
}

variable "ai_project_name" {
  description = "Name of the AI Project"
  type        = string
}

variable "ai_services_id" {
  description = "ID of the AI Services (OpenAI) to link to the AI Hub"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault for the AI Project"
  type        = string
}

variable "key_vault_uri" {
  description = "URI of the Key Vault for linking AI services"
  type        = string
}

# Storage configuration
variable "create_storage" {
  description = "Whether to create a storage account for the AI Hub"
  type        = bool
  default     = false
}

variable "storage_account_name" {
  description = "Name of the storage account for AI Hub"
  type        = string
  default     = ""
}

variable "shared_access_key_enabled" {
  description = "Whether to enable shared access key authentication for the storage account"
  type        = bool
  default     = true
}

variable "store_connection_in_key_vault" {
  description = "Whether to store AI Hub connection information in Key Vault"
  type        = bool
  default     = true
}

# Security configuration
variable "create_role_assignments" {
  description = "Whether to create role assignments"
  type        = bool
  default     = true
}

variable "ai_services_endpoint" {
  description = "Endpoint of the AI Services to link to the AI Hub"
  type        = string
  default     = ""
}

variable "user_principal_id" {
  description = "Principal ID of the user to grant access to AI Hub"
  type        = string
  default     = ""
}

variable "service_principal_ids" {
  description = "Map of service principal IDs to grant access to AI Hub"
  type        = map(string)
  default     = {}
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
