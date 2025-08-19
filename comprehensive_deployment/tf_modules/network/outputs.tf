output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for name, subnet in azurerm_subnet.subnets : name => subnet.id }
}

output "app_service_subnet_id" {
  description = "ID of the App Service subnet"
  value       = azurerm_subnet.subnets["app-service"].id
}

output "private_endpoints_subnet_id" {
  description = "ID of the Private Endpoints subnet"
  value       = azurerm_subnet.subnets["private-endpoints"].id
}

output "gateway_subnet_id" {
  description = "ID of the Gateway subnet"
  value       = try(azurerm_subnet.subnets["gateway"].id, null)
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone names to IDs"
  value       = { for name, zone in azurerm_private_dns_zone.zones : name => zone.id }
}
