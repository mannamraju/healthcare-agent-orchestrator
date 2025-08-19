output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "app_service_subnet_id" {
  description = "The ID of the App Service subnet"
  value       = azurerm_subnet.app_service_subnet.id
}

output "app_nsg_id" {
  description = "The ID of the App Service network security group"
  value       = azurerm_network_security_group.app_nsg.id
}
