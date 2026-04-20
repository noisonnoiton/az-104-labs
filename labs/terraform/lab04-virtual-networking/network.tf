resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.prefix}-hub"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  address_space       = [var.hub_address_space]
  tags                = local.tags
}

resource "azurerm_subnet" "hub_workload" {
  name                 = "snet-workload"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_workload_subnet]
}

resource "azurerm_subnet" "hub_bastion" {
  # Azure Bastion 전용 subnet 이름은 반드시 "AzureBastionSubnet" 여야 함.
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_bastion_subnet]
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${var.prefix}-spoke"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  address_space       = [var.spoke_address_space]
  tags                = local.tags
}

resource "azurerm_subnet" "spoke_workload" {
  name                 = "snet-workload"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.spoke_workload_subnet]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-hub-to-spoke"
  resource_group_name          = data.azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-spoke-to-hub"
  resource_group_name          = data.azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
