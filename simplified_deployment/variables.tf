variable "subscription_id" {
  description = "Azure Subscription ID where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment (e.g., dev, test, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westus"
}

variable "openai_model_capacity" {
  description = "Capacity for the OpenAI model in tokens per minute (TPM) divided by 1000"
  type        = number
  default     = 30
}

variable "clinical_notes_source" {
  description = "Source for clinical notes (fhir, blob, or fabric)"
  type        = string
  default     = "blob"
}
