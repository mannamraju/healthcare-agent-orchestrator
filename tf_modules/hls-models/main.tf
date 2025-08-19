# HLS Models Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Local values
locals {
  # Default instance type if not provided
  actual_instance_type = var.instance_type != "" ? var.instance_type : "Standard_NC24ads_A100_v4"
  
  # Generate a unique postfix for resource names
  postfix = substr(sha1("${var.workspace_name}-${var.resource_group_name}"), 0, 6)
  
  # Model configurations
  models = var.include_radiology_models ? [
    {
      name         = "cxr_report_gen"
      model_id     = "azureml://registries/azureml/models/CxrReportGen/versions/6"
      instance_type = local.actual_instance_type
    }
  ] : []

  # Mock endpoints for development/testing - would be replaced by real endpoints in production
  model_endpoints = var.include_radiology_models ? {
    cxr_report_gen = "https://${var.workspace_name}-cxr-endpoint-${local.postfix}.${var.location}.inference.ml.azure.com"
  } : {}
}

# Note: We're skipping the data source lookup for the workspace since it may not exist yet
# In a real deployment, we would use:
# data "azurerm_machine_learning_workspace" "workspace" {
#   name                = var.workspace_name
#   resource_group_name = var.resource_group_name
# }

# Note: We're using local values instead of resource deployment since
# azurerm_machine_learning_online_endpoint and azurerm_machine_learning_online_deployment
# resources are not available in AzureRM provider v4.0.1.
#
# In a production environment, these would typically be created using either:
# 1. A newer version of the AzureRM provider that supports these resources
# 2. Azure CLI commands through null_resource and local-exec provisioners
# 3. A custom external provider specific to Azure ML
#
# For now, we're using mock endpoints to enable development and testing
