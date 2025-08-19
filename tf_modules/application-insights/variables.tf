variable "app_insights_name" {
  description = "The name of the Application Insights instance"
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

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace to send data to"
  type        = string
  default     = null
}

variable "service_principal_ids" {
  description = "List of service principal IDs to grant monitoring access"
  type        = list(string)
  default     = []
}

variable "user_principal_id" {
  description = "The principal ID of the current user for role assignment"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
