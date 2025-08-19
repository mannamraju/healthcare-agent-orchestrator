variable "healthcare_agent_name" {
  description = "The name of the Healthcare Agent Service Account"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment (e.g., dev, staging, prod) used to make resource names unique"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "bot_sku_name" {
  description = "The SKU name for the healthcare bot"
  type        = string
  default     = "F0" # Free tier by default
}

variable "healthcare_bots" {
  description = "Map of healthcare bots to create"
  type        = map(object({
    name       = string
  }))
  default     = {}
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to store secrets"
  type        = string
  default     = ""
}

variable "create_role_assignments" {
  description = "Whether to create role assignments for the healthcare agent"
  type        = bool
  default     = true
}

variable "user_principal_id" {
  description = "The principal ID of the current user for role assignment"
  type        = string
  default     = ""
}

variable "ai_hub_principal_id" {
  description = "The principal ID of the AI Hub service"
  type        = string
  default     = ""
}

variable "openai_principal_id" {
  description = "The principal ID of the OpenAI service"
  type        = string
  default     = ""
}

variable "service_principal_ids" {
  description = "Map of service principal IDs to assign Healthcare Agent User role"
  type        = map(string)
  default     = {}
}
