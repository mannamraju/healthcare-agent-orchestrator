# HLS Models Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
      version = ">= 2.0.0"
    }
  }
}

# Local values
locals {
  # Default instance type if not provided
  actual_instance_type = var.instance_type != "" ? var.instance_type : "Standard_NC24ads_A100_v4"
  
  # Generate a unique postfix for resource names
  postfix = substr(sha1("${var.workspace_name}-${var.resource_group_name}"), 0, 6)
  
  # Model configurations - matches bicep implementation
  models = var.include_radiology_models ? [
    {
      name          = "cxr_report_gen"
      display_name  = "CXR Report Generation Model"
      model_id      = "azureml://registries/azureml/models/CxrReportGen/versions/6"
      instance_type = local.actual_instance_type
      endpoint_name = "cxr-endpoint-${local.postfix}"
      deployment_name = "cxr-deployment-${local.postfix}"
    }
  ] : []

  # Fully qualified endpoint URLs for the HLS models
  model_endpoints = var.include_radiology_models ? {
    cxr_report_gen = "https://${local.models[0].endpoint_name}.${var.location}.inference.ml.azure.com/score"
  } : {}
}

# Client/subscription context for building workspace parent IDs
data "azurerm_client_config" "current" {}


## AzAPI-based provisioning for ML managed online endpoints and deployments
## NOTE: This was previously attempted and hit schema validation issues around endpointComputeType/traffic.
## Restoring here verbatim so we can iterate and fix with live debugging.

# Managed Online Endpoint
resource "azapi_resource" "ml_online_endpoint" {
  count     = length(local.models)
  type      = "Microsoft.MachineLearningServices/workspaces/onlineEndpoints@2024-10-01"
  name      = local.models[count.index].endpoint_name
  parent_id = var.workspace_id

  body = {
    identity = {
        type = "SystemAssigned"
      }
    location   = var.location
    properties = {
      # AAD-only auth for endpoint
      authMode             = "AADToken"
      publicNetworkAccess  = "Enabled"
      # Optional description/displayName if desired
      description          = local.models[count.index].display_name
    }
  }

  depends_on = [ time_sleep.post_endpoint_delete_pause ]
}

# Managed Online Deployment
resource "azapi_resource" "ml_online_deployment" {
  count     = length(local.models)
  type      = "Microsoft.MachineLearningServices/workspaces/onlineEndpoints/deployments@2024-10-01"
  name      = local.models[count.index].deployment_name
  parent_id = azapi_resource.ml_online_endpoint[count.index].id

  # Known area of contention: exact schema for model/env references and scaleSettings
  body = {
    location   = var.location
    sku = {
      name = "Default"
      tier = "Standard"
      capacity = 1
    }
    properties = {
      endpointComputeType = "Managed"

      model = local.models[count.index].model_id

      # Basic sizing
      instanceType  = local.models[count.index].instance_type

      # Optional scale settings (some API versions expect different shapes)
      scaleSettings = {
        # Target utilization autoscaling
        scaleType = "Default"
      }
    }
  }

  depends_on = [
    azapi_resource.ml_online_endpoint
  ]
}

# Set traffic to this deployment after creation
resource "azapi_update_resource" "ml_endpoint_traffic" {
  count       = length(local.models)
  type        = "Microsoft.MachineLearningServices/workspaces/onlineEndpoints@2024-04-01"
  resource_id = azapi_resource.ml_online_endpoint[count.index].id

  body = {
    properties = {
      traffic = {
        # Route 100% to the single deployment; name must match deployment resource
        (local.models[count.index].deployment_name) = 100
      }
    }
  }

  depends_on = [
    azapi_resource.ml_online_deployment
  ]
}

# Add a delay after endpoint deletion to ensure eventual consistency
# before proceeding with workspace deletion.
resource "time_sleep" "post_endpoint_delete_pause" {
  count            = length(local.models)
  destroy_duration = "90s"
}