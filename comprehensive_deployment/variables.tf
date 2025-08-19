variable "subscription_id" {
  description = "Azure Subscription ID where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where resources will be deployed"
  type        = string
  default     = "hao_0818"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "westus"
}

variable "environment_name" {
  description = "Name of the environment (e.g., dev, test, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "development"
    ManagedBy   = "Terraform"
    Project     = "Healthcare Agent"
  }
}

variable "network_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "network_subnets" {
  description = "Subnet configuration for the virtual network"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string))
    delegations = optional(map(object({
      service_name = string
      actions      = list(string)
    })))
  }))
  default = {
    "app-service" = {
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Web", "Microsoft.KeyVault", "Microsoft.Storage"]
      delegations = {
        "app-service-delegation" = {
          service_name = "Microsoft.Web/serverFarms"
          actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    },
    "private-endpoints" = {
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints = []
    },
    "gateway" = {
      address_prefixes = ["10.0.3.0/24"]
      service_endpoints = []
    }
  }
}

variable "enable_vpn_gateway" {
  description = "Whether to deploy a VPN Gateway"
  type        = bool
  default     = true
}

variable "create_private_endpoints" {
  description = "Whether to create private endpoints for secure access to Azure services"
  type        = bool
  default     = true
}

variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "P1v2"
}

variable "app_settings" {
  description = "Additional app settings for the Healthcare Agent App Service"
  type        = map(string)
  default     = {}
}

variable "bot_names" {
  description = "Names of the bots to create"
  type        = list(string)
  default = [
    "ClinicalGuidelines",
    "ClinicalTrials",
    "magentic",
    "MedicalResearch",
    "Orchestrator",
    "PatientHistory",
    "PatientStatus",
    "Radiology",
    "ReportCreation"
  ]
}

variable "ai_model_deployments" {
  description = "OpenAI model deployments to create"
  type = list(object({
    name     = string
    model    = string
    version  = string
    capacity = number
  }))
  default = [
    {
      name     = "gpt4o"
      model    = "gpt-4o"
      version  = "2024-08-06"
      capacity = 30
    }
  ]
}
