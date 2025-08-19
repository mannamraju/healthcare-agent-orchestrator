variable "workspace_name" {
  description = "The name of the Azure ML workspace"
  type        = string
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
  default     = ""
}

variable "include_radiology_models" {
  description = "Whether to include radiology models in the deployment"
  type        = bool
  default     = false
}
