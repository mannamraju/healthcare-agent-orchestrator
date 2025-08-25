# Healthcare Agent Orchestrator - Variable Definitions
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Core Configuration Variables
variable "subscription_id" {
  description = "Azure Subscription ID where resources will be deployed"
  type        = string
}
variable "environment_name" {
  description = "Name of the environment (e.g., dev, staging, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group where resources will be deployed"
  type        = string
}

variable "storage_shared_access_key_enabled" {
  description = "Controls whether Storage Account shared access keys are enabled"
  type        = bool
  default     = false # Default to false for new deployments to comply with subscription policies
}

variable "scenario" {
  description = "The scenario configuration to use for deployment"
  type        = string
  default     = "default"
}

# Clinical notes configuration
variable "clinical_notes_source" {
  description = "Source for clinical notes (blob, fhir, or fabric)"
  type        = string
  default     = "blob"
  validation {
    condition     = contains(["blob", "fhir", "fabric"], var.clinical_notes_source)
    error_message = "clinical_notes_source must be one of: blob, fhir, fabric."
  }
}

variable "fhir_service_endpoint" {
  description = "Existing FHIR service endpoint to use (skip deployment if provided)"
  type        = string
  default     = ""
}

# Virtual Network Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "default"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

# Principal Configuration
variable "my_principal_id" {
  description = "Principal ID to grant access to AI services and Key Vault (leave empty to skip)"
  type        = string
  default     = ""
}

variable "my_principal_type" {
  description = "Type of the principal (User or ServicePrincipal)"
  type        = string
  default     = "User"
  validation {
    condition     = contains(["User", "ServicePrincipal"], var.my_principal_type)
    error_message = "Principal type must be either 'User' or 'ServicePrincipal'."
  }
}

# Authentication Configuration
variable "auth_client_id" {
  description = "Client ID for Azure AD application used for authentication (leave empty to skip authentication setup)"
  type        = string
  default     = ""
}

# OpenAI Model Configuration
variable "openai_model" {
  description = "OpenAI model name and version in format 'model;version' (e.g., 'gpt-4o;2024-08-06')"
  type        = string
  validation {
    condition     = contains(["gpt-4o;2024-08-06", "gpt-4.1;2025-04-14"], var.openai_model)
    error_message = "OpenAI model must be one of the supported models: gpt-4o;2024-08-06, gpt-4.1;2025-04-14"
  }
}

variable "enable_openai" {
  description = "Whether to deploy OpenAI services (requires Azure OpenAI access approval)"
  type        = bool
  default     = false
}

variable "openai_model_capacity" {
  description = "Tokens per minute capacity for the OpenAI model in thousands (e.g., 100 = 100K TPM)"
  type        = number
  default     = 100
}

variable "openai_model_sku" {
  description = "Deployment type for the OpenAI model (Standard, GlobalStandard, GlobalBatch, or ProvisionedManaged)"
  type        = string
  default     = "GlobalStandard"
  validation {
    condition     = contains(["Standard", "GlobalStandard", "GlobalBatch", "ProvisionedManaged"], var.openai_model_sku)
    error_message = "Model SKU must be one of: 'Standard', 'GlobalStandard', 'GlobalBatch', or 'ProvisionedManaged'."
  }
}

## App access allowlists (prefer list inputs in Terraform)
variable "additional_allowed_ips" {
  description = "Additional public IPv4/CIDR addresses to allow through App Service access restrictions"
  type        = list(string)
  default     = []
}

variable "additional_allowed_tenant_ids" {
  description = "Additional Azure AD tenant IDs allowed by the application (used by app auth layer)"
  type        = list(string)
  default     = []
}

variable "additional_allowed_user_ids" {
  description = "Additional Azure AD user object IDs allowed by the application (used by app auth layer)"
  type        = list(string)
  default     = []
}

# AI Workspace Configuration
variable "existing_ai_workspace_name" {
  description = "Name of existing Azure ML workspace to use for GPU deployments (leave empty to create new workspace)"
  type        = string
  default     = ""
}

# Resource Naming Overrides (Optional - will auto-generate if not provided)
variable "ai_services_name" {
  description = "Custom name for AI Services account (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "ai_hub_name" {
  description = "Custom name for AI Hub resource (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Custom name for main Storage Account (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "app_storage_account_name" {
  description = "Custom name for App Service Storage Account used for chat sessions and patient data (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "key_vault_name" {
  description = "Custom name for Key Vault (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "managed_identity_name" {
  description = "Custom name for Managed Identity (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "app_service_plan_name" {
  description = "Custom name for App Service Plan (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "app_service_plan_sku" {
  description = "SKU name for the App Service Plan (e.g., S1, P1v2, P1v3)"
  type        = string
  default     = ""
}

variable "app_service_name" {
  description = "Custom name for App Service (auto-generated if empty)"
  type        = string
  default     = ""
}

# Location Configuration
variable "resource_group_location" {
  description = "Azure region for Resource Group deployment"
  type        = string
  default     = "westus"
}

variable "gpt_deployment_location" {
  description = "Azure region for OpenAI/GPT model deployment"
  type        = string
  default     = ""
}

variable "hls_deployment_location" {
  description = "Azure region for Healthcare and Life Sciences (HLS) model deployment"
  type        = string
  default     = ""
}

variable "app_service_location" {
  description = "Azure region for App Service deployment"
  type        = string
  default     = ""
}

variable "bot_service_location" {
  description = "Azure region for Bot Service deployment (typically 'global')"
  type        = string
  default     = "global"
}

variable "healthcare_agent_service_location" {
  description = "Azure region for Healthcare Agent Service deployment"
  type        = string
  default     = ""
}

variable "key_vault_location" {
  description = "Azure region for Key Vault deployment"
  type        = string
  default     = ""
}

variable "managed_identity_location" {
  description = "Azure region for Managed Identity deployment"
  type        = string
  default     = ""
}

variable "storage_account_location" {
  description = "Azure region for Storage Account deployment"
  type        = string
  default     = ""
}

# Healthcare and Life Sciences Configuration
variable "instance_type" {
  description = "VM instance type for HLS model deployments (leave empty for default)"
  type        = string
  default     = ""
}

variable "hls_model_endpoints" {
  description = "HLS model endpoints. This is usually auto-generated by the HLS model deployment module, but can be overridden here."
  type        = map(string)
  default     = {}
}

# External Service Configuration
variable "graph_rag_subscription_key" {
  description = "Subscription key for Graph RAG service (sensitive)"
  type        = string
  default     = ""
  sensitive   = true
}

# Resource Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# GPU Deployment Variables
# Added by deploy_gpu.sh for Healthcare Agent Orchestrator

variable "include_gpu_models" {
  description = "Deploy GPU-enabled models for radiology analysis"
  type        = bool
  default     = false
}

variable "gpu_instance_type" {
  description = "GPU VM instance type for model deployments (single-zone, cost-optimized)"
  type        = string
  default     = "Standard_NC24ads_A100_v4"
  validation {
    condition     = can(regex("^Standard_(NC|ND|NV)", var.gpu_instance_type))
    error_message = "GPU instance type must be a valid GPU VM SKU (NC, ND, or NV series)."
  }
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
  description = "Enable zone redundancy for GPU deployments (disabled for cost optimization)"
  type        = bool
  default     = false
}

variable "reasoning_model_endpoint" {
  description = "Optional separate endpoint for reasoning model (leave empty to use main OpenAI endpoint)"
  type        = string
  default     = ""
}

variable "reasoning_model_deployment_name" {
  description = "Deployment name for reasoning model"
  type        = string
  default     = ""
}
