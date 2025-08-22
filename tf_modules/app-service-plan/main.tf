# App Service Plan Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Linux App Service Plan
resource "azurerm_service_plan" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  
  os_type  = "Linux"
  sku_name = var.sku_name
}
