variable "workspace_name" {
  description = "The name of the Azure ML workspace"
  type        = string
}

variable "workspace_id" {
  description = "The full resource ID of the Azure ML workspace (AI Project). Prefer using this over name to avoid lookup/race conditions."
  type        = string
  default     = ""
}

variable "location" {
  description = "The Azure region where the HLS models should be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "instance_type" {
  description = "The VM instance type for model deployment"
  type        = string
  default     = "Standard_NC24ads_A100_v4" # Default to an A100 GPU instance
}

variable "include_radiology_models" {
  description = "Whether to include radiology models in the deployment"
  type        = bool
  default     = false
}

variable "deployment_timeout" {
  description = "Timeout for model deployment operations in minutes"
  type        = number
  default     = 45
}

variable "enable_application_insights" {
  description = "Enable Application Insights monitoring for endpoints"
  type        = bool
  default     = true
}

variable "max_concurrent_requests" {
  description = "Maximum concurrent requests per instance for model deployments"
  type        = number
  default     = 1
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for GPU deployments"
  type        = bool
  default     = false
}
