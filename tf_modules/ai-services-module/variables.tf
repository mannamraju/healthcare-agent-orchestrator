# Variables for AI Services Module

# Required variables
variable "resource_group_name" {
  description = "Name of the resource group where resources will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for AI services"
  type        = string
}

variable "ai_services_name" {
  description = "Name of the Azure OpenAI service"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault where to store secrets"
  type        = string
  default     = ""
}

# OpenAI configuration
variable "openai_sku_name" {
  description = "SKU for the OpenAI service"
  type        = string
  default     = "S0"
}

# Model configuration
variable "model_deployment_name" {
  description = "Name of the model deployment"
  type        = string
  default     = "gpt35turbo"
}

variable "model_name" {
  description = "Name of the OpenAI model to deploy"
  type        = string
  default     = "gpt-35-turbo"
}

variable "model_version" {
  description = "Version of the OpenAI model"
  type        = string
  default     = "1106"
}

variable "model_capacity" {
  description = "Capacity/Tokens-per-minute for the model deployment"
  type        = number
  default     = 30
}

# Security configuration
variable "create_role_assignments" {
  description = "Whether to create role assignments"
  type        = bool
  default     = true
}

variable "store_secrets_in_keyvault" {
  description = "Whether to store OpenAI secrets in Key Vault"
  type        = bool
  default     = true
}

variable "user_principal_id" {
  description = "Principal ID of the user to grant access to OpenAI"
  type        = string
  default     = ""
}

variable "service_principal_ids" {
  description = "Map of service principal IDs to grant access to OpenAI"
  type        = map(string)
  default     = {}
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
