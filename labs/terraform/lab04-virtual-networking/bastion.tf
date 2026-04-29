resource "azurerm_public_ip" "bastion" {
  name                = "pip-bas-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# Basic SKU: Hub VNet 에 배포됨.
# Hub 의 Bastion 은 Peering 을 통해 Spoke VM 에도 접근 가능하지만,
# Spoke NSG 에서 AzureBastionSubnet 출처 SSH 를 허용하지 않으므로
# Bastion 에서 vm-spoke 로 직접 접속이 차단됨 (점프 서버 패턴).
resource "azurerm_bastion_host" "this" {
  name                = "bas-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  sku                 = "Basic"
  tags                = local.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
