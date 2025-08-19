# Virtual Network Module Outputs
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = azurerm_subnet.main.name
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "app_service_subnet_id" {
  description = "ID of the subnet for App Service integration"
  value       = azurerm_subnet.main.id
}
