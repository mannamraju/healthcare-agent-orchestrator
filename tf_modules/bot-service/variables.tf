variable "location" {
  description = "The Azure region where the bot services should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "app_backend_hostname" {
  description = "The hostname of the backend app service"
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID for the Azure AD application"
  type        = string
}

variable "unique_suffix" {
  description = "A unique suffix to add to resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the bot services"
  type        = map(string)
  default     = {}
}

variable "sku" {
  description = "The SKU of the Bot Service"
  type        = string
  default     = "F0"
}

variable "bots" {
  description = "A map of bot configurations"
  type = map(object({
    client_id = string
    id        = string
    name      = string
  }))
}
