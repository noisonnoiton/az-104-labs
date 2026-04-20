resource "azurerm_private_dns_zone" "internal" {
  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "link-hub"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.internal.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  name                  = "link-spoke"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.internal.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_a_record" "hub_vm" {
  name                = "vm-hub"
  zone_name           = azurerm_private_dns_zone.internal.name
  resource_group_name = data.azurerm_resource_group.this.name
  ttl                 = 300
  records             = [azurerm_network_interface.hub_vm.private_ip_address]
  tags                = local.tags
}

resource "azurerm_private_dns_a_record" "spoke_vm" {
  name                = "vm-spoke"
  zone_name           = azurerm_private_dns_zone.internal.name
  resource_group_name = data.azurerm_resource_group.this.name
  ttl                 = 300
  records             = [azurerm_network_interface.spoke_vm.private_ip_address]
  tags                = local.tags
}
