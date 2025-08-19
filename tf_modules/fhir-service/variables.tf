variable "workspace_name" {
  description = "The name of the Healthcare Workspace"
  type        = string
}

variable "fhir_service_name" {
  description = "The name of the FHIR service"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account for FHIR service export configuration"
  type        = string
  default     = ""
}

variable "data_contributors" {
  description = "List of identities to grant data contributor access"
  type        = list(object({
    id   = string
    type = string
  }))
  default     = []
}

variable "data_readers" {
  description = "List of identities to grant data reader access"
  type        = list(object({
    id   = string
    type = string
  }))
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
