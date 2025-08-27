variable "name" {
  description = "The name of the app service"
  type        = string
}

variable "location" {
  description = "The Azure region where the app service should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "app_service_plan_id" {
  description = "The ID of the app service plan"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the app service"
  type        = map(string)
  default     = {}
}

variable "key_vault_id" {
  description = "The ID of the key vault"
  type        = string
}

variable "key_vault_uri" {
  description = "The URI of the key vault"
  type        = string
}

variable "app_blob_storage_endpoint" {
  description = "The blob storage endpoint for the app"
  type        = string
}

variable "ai_project_name" {
  description = "The name of the AI project"
  type        = string
}

variable "ai_project_connection_string" {
  description = "The connection string for the AI project"
  type        = string
}

variable "managed_identities" {
  description = "A map of managed identities to use for the app service"
  type        = map(any)
}

variable "openai_endpoint" {
  description = "The endpoint for Azure OpenAI"
  type        = string
}

variable "openai_endpoint_reasoning_model" {
  description = "The endpoint for the reasoning model in Azure OpenAI"
  type        = string
  default     = ""
}

variable "deployment_name" {
  description = "The deployment name for the OpenAI model"
  type        = string
}

variable "deployment_name_reasoning_model" {
  description = "The deployment name for the reasoning model"
  type        = string
  default     = ""
}

variable "auth_client_id" {
  description = "The client ID for authentication"
  type        = string
  default     = ""
}

variable "graph_rag_subscription_key" {
  description = "The subscription key for Graph RAG"
  type        = string
  default     = ""
}

variable "scenario" {
  description = "The scenario to deploy"
  type        = string
  default     = "default"
}

variable "application_insights_connection_string" {
  description = "The connection string for Application Insights"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The subnet ID for VNet integration"
  type        = string
  default     = ""
}

variable "additional_allowed_ips" {
  description = "Additional IPs to allow in network rules"
  type        = list(string)
  default     = []
}

variable "additional_allowed_tenant_ids" {
  description = "Additional tenant IDs to allow for authentication"
  type        = list(string)
  default     = []
}

variable "additional_allowed_user_ids" {
  description = "Additional user IDs to allow for authentication (user object IDs)"
  type        = list(string)
  default     = []
}

variable "clinical_notes_source" {
  description = "Source for clinical notes (fhir or fabric)"
  type        = string
  default     = "none"
}

variable "fhir_service_endpoint" {
  description = "The endpoint for the FHIR service"
  type        = string
  default     = ""
}

variable "fabric_user_data_function_endpoint" {
  description = "The endpoint for the Fabric user data function"
  type        = string
  default     = ""
}

variable "model_endpoints" {
  description = "Endpoints for HLS models"
  type        = map(string)
  default     = {}
}
