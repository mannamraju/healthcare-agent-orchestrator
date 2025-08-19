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

variable "app_service_plan_id" {
  description = "ID of the App Service Plan"
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

variable "app_insights_key" {
  description = "Instrumentation key for Application Insights"
  type        = string
}

variable "storage_connection" {
  description = "Connection string for storage account"
  type        = string
}

variable "keyvault_url" {
  description = "URL of the Key Vault"
  type        = string
}

variable "ai_endpoint" {
  description = "Endpoint of the AI service"
  type        = string
}

variable "ai_key" {
  description = "API key for the AI service"
  type        = string
}

variable "app_settings" {
  description = "Additional app settings for the App Service"
  type        = map(string)
  default     = {}
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
