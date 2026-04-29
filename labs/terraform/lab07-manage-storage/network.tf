resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  address_space       = [var.vnet_address_space]
  tags                = local.tags
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_prefix]
  service_endpoints    = ["Microsoft.Storage"]
}
