# Managed Identity Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
