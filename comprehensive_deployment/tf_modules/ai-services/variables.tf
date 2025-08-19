variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for private endpoints"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Map of private DNS zone names to IDs"
  type        = map(string)
}

variable "create_private_endpoints" {
  description = "Whether to create private endpoints"
  type        = bool
  default     = true
}

variable "ai_model_deployments" {
  description = "OpenAI model deployments to create"
  type = list(object({
    name     = string
    model    = string
    version  = string
    capacity = number
  }))
  default = [
    {
      name     = "gpt4o"
      model    = "gpt-4o"
      version  = "2024-08-06"
      capacity = 30
    }
  ]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
