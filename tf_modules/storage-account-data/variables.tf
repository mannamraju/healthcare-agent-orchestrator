variable "name" {
  description = "The name of the storage account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the storage account should be created"
  type        = string
}

variable "subscription_id" {
  description = "The Azure Subscription ID where the storage account exists"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
  default     = {}
}

variable "user_principal_id" {
  description = "The principal ID of the current user for role assignment"
  type        = string
  default     = ""
}

variable "user_principal_type" {
  description = "The type of the principal (User or ServicePrincipal)"
  type        = string
  default     = "User"
}

variable "service_principal_ids" {
  description = "Map of service principal IDs to grant access to the storage account"
  type        = map(string)
  default     = {}
}
