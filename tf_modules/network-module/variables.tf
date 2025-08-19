variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_address_prefixes" {
  description = "The address prefixes for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_service_subnet_prefix" {
  description = "The address prefix for the App Service subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
