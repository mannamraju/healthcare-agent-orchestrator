variable "name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "location" {
  description = "The Azure region where the Key Vault should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Key Vault"
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
  description = "Map of service principal IDs to grant access to the Key Vault"
  type        = map(string)
  default     = {}
}

variable "graph_rag_subscription_key" {
  description = "The subscription key for Graph RAG (if any)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the Key Vault (VNet rules)"
  type        = list(string)
  default     = []
}
