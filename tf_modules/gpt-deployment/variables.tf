variable "ai_services_id" {
  description = "The ID of the AI Services account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "model_name" {
  description = "The name of the GPT model to deploy"
  type        = string
}

variable "model_version" {
  description = "The version of the GPT model to deploy"
  type        = string
}

variable "model_capacity" {
  description = "The capacity of the GPT model in tokens per minute (TPM) divided by 1000"
  type        = number
  default     = 30
}

variable "model_sku" {
  description = "The SKU for the GPT model"
  type        = string
  default     = "Standard"
}
