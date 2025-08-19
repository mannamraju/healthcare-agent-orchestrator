# Variables for Healthcare Agent deployment

# Core Configuration
variable "subscription_id" {
  description = "Azure Subscription ID where resources will be deployed"
  type        = string
  default     = "69642945-f464-4724-ba83-205eecbe5937"
}

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "hao_0816"
}

variable "location" {
  description = "Azure region for Healthcare Agent"
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

variable "ai_hub_name" {
  description = "Name of the existing AI Hub"
  type        = string
  default     = "aihub-hao-0816"
}

# Healthcare Agent Configuration
variable "healthcare_agent_name" {
  description = "Name of the Healthcare Agent Service Account"
  type        = string
  default     = "hao-agent-service"
}

variable "bot_sku_name" {
  description = "The SKU name for the healthcare bot"
  type        = string
  default     = "F0"  # Free tier
}

variable "healthcare_bots" {
  description = "Map of healthcare bots to create"
  type        = map(object({
    name       = string
  }))
  default     = {
    "radiology" = {
      name = "radiology-bot"
    },
    "clinical_guidelines" = {
      name = "clinical-guidelines-bot"
    },
    "patient_history" = {
      name = "patient-history-bot"
    }
  }
}

# Security configuration
variable "create_role_assignments" {
  description = "Whether to create role assignments"
  type        = bool
  default     = true
}

variable "service_principal_ids" {
  description = "Map of service principal IDs to grant access to Healthcare Agent"
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
    Component   = "Healthcare Agent"
    ManagedBy   = "Terraform"
    CreatedDate = "2025-08-16"
  }
}
