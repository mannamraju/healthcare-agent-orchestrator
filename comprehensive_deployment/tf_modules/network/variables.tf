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

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "Subnet configuration for the virtual network"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    delegations = optional(map(object({
      service_name = string
      actions      = list(string)
    })), {})
  }))
}

variable "enable_vpn_gateway" {
  description = "Whether to deploy a VPN Gateway"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
