# GPT Deployment Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Reference to existing AI Services account
locals {
  ai_services_id = var.ai_services_id
}

# OpenAI Model Deployment
resource "azurerm_cognitive_deployment" "gpt_model" {
  count = substr(var.model_name, 0, 3) == "gpt" ? 1 : 0
  
  name                 = var.model_name
  cognitive_account_id = local.ai_services_id
  
  # Add lifecycle configuration to prevent recreation if there are issues
  lifecycle {
    ignore_changes = [
      sku[0].capacity
    ]
    # This will prevent recreation due to capacity issues but still create the deployment
    create_before_destroy = true
  }
  
  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version
  }
  
  sku {
    name     = var.model_sku
    capacity = var.model_capacity
  }
}
