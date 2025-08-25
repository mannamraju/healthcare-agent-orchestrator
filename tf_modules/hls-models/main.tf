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
  
  # Toggle: set to true to use CLI-based provisioning instead of AzAPI
  enable_cli_provisioning = false
  
  # Model configurations - matches bicep implementation
  models = var.include_radiology_models ? [
    {
      name          = "cxr_report_gen"
      display_name  = "CXR Report Generation Model"
      model_id      = "azureml://registries/azureml/models/CxrReportGen/versions/6"
      instance_type = local.actual_instance_type
      endpoint_name = "cxr-endpoint-${local.postfix}"
      deployment_name = "cxr-deployment-${local.postfix}"
      scale_settings = {
        min_instances = 1
        max_instances = 5
      }
    }
  ] : []

  # Fully qualified endpoint URLs for the HLS models
  model_endpoints = var.include_radiology_models ? {
    cxr_report_gen = "https://${local.models[0].endpoint_name}.${var.location}.inference.ml.azure.com/score"
  } : {}
}

## CLI-based provisioning for ML endpoints and deployments (idempotent)
## Disabled by default in favor of AzAPI resources below; flip local.enable_cli_provisioning to true to re-enable.
resource "null_resource" "hls_model_deployment" {
  count = local.enable_cli_provisioning ? length(local.models) : 0

  triggers = {
    model_name       = local.models[count.index].name
    model_id         = local.models[count.index].model_id
    instance_type    = local.models[count.index].instance_type
    endpoint_name    = local.models[count.index].endpoint_name
    deployment_name  = local.models[count.index].deployment_name
    workspace_name   = var.workspace_name
    resource_group   = var.resource_group_name
    location         = var.location
  }

  # Create the ML online endpoint (AAD auth). If it already exists, skip creation.
  provisioner "local-exec" {
    command = <<EOF
      set -euo pipefail
      if ! az ml online-endpoint show \
        --name ${local.models[count.index].endpoint_name} \
        --resource-group ${var.resource_group_name} \
        --workspace-name ${var.workspace_name} >/dev/null 2>&1; then
        az ml online-endpoint create \
          --name ${local.models[count.index].endpoint_name} \
          --resource-group ${var.resource_group_name} \
          --workspace-name ${var.workspace_name} \
          --auth-mode aad_token
      fi
    EOF
  }

  # Create or update the model deployment with GPU acceleration, and set as default
  provisioner "local-exec" {
    command = <<EOF
      set -euo pipefail
      if az ml online-deployment show \
        --name ${local.models[count.index].deployment_name} \
        --endpoint-name ${local.models[count.index].endpoint_name} \
        --resource-group ${var.resource_group_name} \
        --workspace-name ${var.workspace_name} >/dev/null 2>&1; then
        az ml online-deployment update \
          --name ${local.models[count.index].deployment_name} \
          --endpoint-name ${local.models[count.index].endpoint_name} \
          --resource-group ${var.resource_group_name} \
          --workspace-name ${var.workspace_name} \
          --model ${local.models[count.index].model_id} \
          --instance-type ${local.models[count.index].instance_type} \
          --instance-count ${local.models[count.index].scale_settings.min_instances} \
          --set-default
      else
        az ml online-deployment create \
          --name ${local.models[count.index].deployment_name} \
          --endpoint-name ${local.models[count.index].endpoint_name} \
          --resource-group ${var.resource_group_name} \
          --workspace-name ${var.workspace_name} \
          --model ${local.models[count.index].model_id} \
          --instance-type ${local.models[count.index].instance_type} \
          --instance-count ${local.models[count.index].scale_settings.min_instances} \
          --set-default
      fi
    EOF
  }
}

# Client/subscription context for building workspace parent IDs
data "azurerm_client_config" "current" {}

# Build the parent resource ID for the AML workspace
locals {
  aml_workspace_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.MachineLearningServices/workspaces/${var.workspace_name}"
}

## AzAPI-based provisioning for ML managed online endpoints and deployments
## NOTE: This was previously attempted and hit schema validation issues around endpointComputeType/traffic.
## Restoring here verbatim so we can iterate and fix with live debugging.

# Managed Online Endpoint
resource "azapi_resource" "ml_online_endpoint" {
  count     = length(local.models)
  type      = "Microsoft.MachineLearningServices/workspaces/onlineEndpoints@2024-04-01"
  name      = local.models[count.index].endpoint_name
  parent_id = local.aml_workspace_id

  body = {
    location   = var.location
    properties = {
      # AAD-only auth for endpoint
      authMode             = "AADToken"
      # Optional description/displayName if desired
      description          = local.models[count.index].display_name
    }
  }
}

# Managed Online Deployment
resource "azapi_resource" "ml_online_deployment" {
  count     = length(local.models)
  type      = "Microsoft.MachineLearningServices/workspaces/onlineEndpoints/deployments@2024-04-01"
  name      = local.models[count.index].deployment_name
  parent_id = azapi_resource.ml_online_endpoint[count.index].id

  # Known area of contention: exact schema for model/env references and scaleSettings
  body = {
    properties = {
      endpointComputeType = "Managed"

      model = local.models[count.index].model_id

      # Basic sizing
      instanceType  = local.models[count.index].instance_type

      # Optional scale settings (some API versions expect different shapes)
      scaleSettings = {
        # Target utilization autoscaling
        scaleType                     = "TargetUtilization"
        minInstances                  = local.models[count.index].scale_settings.min_instances
        maxInstances                  = local.models[count.index].scale_settings.max_instances
        targetUtilizationPercentage   = 70
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
