# Bot Service Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Local values for bot icons (base64 encoded)
locals {
  bot_icons = {
    "Orchestrator"       = filebase64("${path.module}/../../infra/botIcons/Orchestrator.png")
    "PatientHistory"     = filebase64("${path.module}/../../infra/botIcons/PatientHistory.png")
    "Radiology"          = filebase64("${path.module}/../../infra/botIcons/Radiology.png")
    "ReportCreation"     = filebase64("${path.module}/../../infra/botIcons/ReportCreation.png")
    "ClinicalGuidelines" = filebase64("${path.module}/../../infra/botIcons/ClinicalGuidelines.png")
    "PatientStatus"      = filebase64("${path.module}/../../infra/botIcons/PatientStatus.png")
    "ClinicalTrials"     = filebase64("${path.module}/../../infra/botIcons/ClinicalTrials.png")
  }
}

# Bot Services
resource "azurerm_bot_service_azure_bot" "bots" {
  for_each = var.bots
  
  name                = "${each.value.name}-${var.unique_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  
  sku                 = var.sku
  microsoft_app_id    = each.value.client_id
  microsoft_app_msi_id = each.value.id
  microsoft_app_type  = "UserAssignedMSI"
  microsoft_app_tenant_id = var.tenant_id
  
  display_name        = each.value.name
  endpoint           = "https://${var.app_backend_hostname}/api/${each.value.name}/messages"
  
  icon_url           = "data:image/png;base64,${lookup(local.bot_icons, each.value.name, local.bot_icons["Orchestrator"])}"
  
  public_network_access_enabled = true
  local_authentication_enabled  = false
}

# Teams Channel for each bot
resource "azurerm_bot_channel_ms_teams" "teams_channels" {
  for_each = var.bots
  
  bot_name            = azurerm_bot_service_azure_bot.bots[each.key].name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  calling_web_hook         = null
  enable_calling           = true
  deployment_environment   = "CommercialDeployment"
}
