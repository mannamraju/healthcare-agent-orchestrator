# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# Variables for AI Hub deployment

# Core Configuration

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "hao_0816"
}

variable "key_vault_id" {
  description = "ID of the key vault"
  type        = string
}

variable "key_vault_uri" {
  description = "URI of the key vault"
  type        = string
}

variable "location" {
  description = "Azure region for AI Hub"
  type        = string
  default     = "westus"
}

variable "key_vault_name" {
  description = "Name of the existing key vault"
  type        = string
  default     = "kv-westus-hao0816"
}

variable "ai_services_name" {
  description = "Name of the existing OpenAI services account"
  type        = string
  default     = "oai-hao-0816"
}

# AI Hub Configuration
variable "ai_hub_name" {
  description = "Name of the AI Hub"
  type        = string
  default     = "aihub-hao-0816"
}

variable "ai_project_name" {
  description = "Name of the AI Project"
  type        = string
  default     = "ai-project-hao-0816"
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
  default     = "aihubhao0816st"
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

variable "openai_account_id" {
  description = "Existing OpenAI Cognitive Account ID"
  type        = string
}

# Security configuration
variable "create_role_assignments" {
  description = "Whether to create role assignments"
  type        = bool
  default     = true
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
  default = {
    Environment = "Development"
    Project     = "Healthcare Agent Orchestrator"
    Component   = "AI Hub"
    ManagedBy   = "Terraform"
    CreatedDate = "2025-08-16"
  }
}
