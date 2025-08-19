# Variables for AI Services deployment

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
  description = "Azure region for AI services"
  type        = string
  default     = "westus"
}

variable "key_vault_name" {
  description = "Name of the existing key vault"
  type        = string
  default     = "kv-westus-hao0816"
}

variable "key_vault_id" {
  description = "ID of the key vault"
  type        = string
}

# AI Services Configuration
variable "ai_services_name" {
  description = "Name of the AI services account"
  type        = string
  default     = "oai-hao-0816"
}

variable "openai_sku_name" {
  description = "SKU for the OpenAI service"
  type        = string
  default     = "S0"
}

# Model Configuration
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

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "Healthcare Agent Orchestrator"
    Component   = "AI Services"
    ManagedBy   = "Terraform"
    CreatedDate = "2025-08-16"
  }
}
