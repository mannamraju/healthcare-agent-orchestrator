# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# Variables for AI Hub deployment

## Required inputs used by the module

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "location" {
  description = "Azure region for AI Hub"
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault"
  type        = string
}

variable "storage_account_id" {
  description = "Resource ID of the Storage Account for the AI Hub"
  type        = string
}

variable "ai_hub_name" {
  description = "Name of the AI Hub"
  type        = string
}

variable "ai_project_name" {
  description = "Name of the AI Project"
  type        = string
}

variable "openai_account_id" {
  description = "Existing Azure OpenAI (Cognitive Services) account resource ID"
  type        = string
}

variable "ai_services_endpoint" {
  description = "Endpoint URL of the Azure AI/OpenAI account to connect from AI Hub"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Optional role assignments (parity with Bicep)
variable "create_role_assignments" {
  description = "Whether to create AI Developer role assignments for provided principals and OpenAI Contributor assignment for the Project"
  type        = bool
  default     = false
}

variable "service_principal_ids" {
  description = "Map of service principal IDs to grant AI Developer on Hub and Project"
  type        = map(string)
  default     = {}
}

variable "user_principal_id" {
  description = "Optional user principal ID to grant AI Developer on Hub and Project"
  type        = string
  default     = ""
}

variable "user_principal_type" {
  description = "Principal type for the user_principal_id (User or ServicePrincipal)"
  type        = string
  default     = "User"
}
