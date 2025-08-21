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

# For real production deployments, we would use azurerm provider resources directly
# However, since azurerm_machine_learning_online_endpoint is not available in v4.0,
# we'll use a null_resource with local-exec to deploy using Azure CLI
resource "null_resource" "hls_model_deployment" {
  count = length(local.models)

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

  # First, ensure the workspace exists (would be created by the AI Hub module)

  # Create the ML online endpoint
  provisioner "local-exec" {
    command = <<EOF
      az ml online-endpoint create \
        --name ${local.models[count.index].endpoint_name} \
        --resource-group ${var.resource_group_name} \
        --workspace-name ${var.workspace_name} \
        --location ${var.location} \
        --auth-mode key
    EOF
  }

  # Create the model deployment with GPU acceleration
  provisioner "local-exec" {
    command = <<EOF
      az ml online-deployment create \
        --name ${local.models[count.index].deployment_name} \
        --endpoint-name ${local.models[count.index].endpoint_name} \
        --resource-group ${var.resource_group_name} \
        --workspace-name ${var.workspace_name} \
        --model-name ${local.models[count.index].name} \
        --model ${local.models[count.index].model_id} \
        --instance-type ${local.models[count.index].instance_type} \
        --instance-count ${local.models[count.index].scale_settings.min_instances} \
        --set-default
    EOF
  }

  # Clean up on destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      az ml online-endpoint delete \
        --name ${self.triggers.endpoint_name} \
        --resource-group ${self.triggers.resource_group} \
        --workspace-name ${self.triggers.workspace_name} \
        --yes
    EOF
  }
}
