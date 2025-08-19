variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "ai_hub_name" {
  description = "Name of the AI Hub"
  type        = string
}

variable "ai_service_id" {
  description = "ID of the AI Services account"
  type        = string
}

variable "container_registry_name" {
  description = "Name of the container registry for the AI Hub"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
