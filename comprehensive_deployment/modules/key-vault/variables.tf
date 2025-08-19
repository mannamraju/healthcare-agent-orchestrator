variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name" {
  description = "Name of the key vault"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
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

variable "create_private_endpoint" {
  description = "Whether to create private endpoints"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
