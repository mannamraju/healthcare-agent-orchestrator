# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = "${each.key}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "app_service_nsg" {
  name                = "appservice-subnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "app_service_nsg_association" {
  subnet_id                 = azurerm_subnet.subnets["app-service"].id
  network_security_group_id = azurerm_network_security_group.app_service_nsg.id
}

resource "azurerm_network_security_group" "private_endpoints_nsg" {
  name                = "private-endpoints-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints_nsg_association" {
  subnet_id                 = azurerm_subnet.subnets["private-endpoints"].id
  network_security_group_id = azurerm_network_security_group.private_endpoints_nsg.id
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "zones" {
  for_each = {
    "privatelink.azurewebsites.net"        = "App Service"
    "privatelink.blob.core.windows.net"    = "Storage Blob"
    "privatelink.vaultcore.azure.net"      = "Key Vault"
    "privatelink.cognitiveservices.azure.com" = "Cognitive Services"
  }

  name                = each.key
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# DNS Zone VNet links
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_links" {
  for_each = azurerm_private_dns_zone.zones

  name                  = "${var.name_prefix}-${each.key}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
  tags                  = var.tags
}

# VPN Gateway (conditional)
resource "azurerm_public_ip" "vpn_gateway_pip" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "vnet-${var.name_prefix}-vpngw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "vnet-${var.name_prefix}-vpngw"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "Basic"
  enable_bgp          = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets["gateway"].id
  }

  tags = var.tags
}
