resource "azurerm_application_security_group" "app" {
  name                = "asg-${var.prefix}-app"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

resource "azurerm_network_security_group" "workload" {
  name                = "nsg-${var.prefix}-workload"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

# Bastion subnet 에서 오는 SSH (22/TCP) 만 허용.
resource "azurerm_network_security_rule" "allow_ssh_from_bastion" {
  name                        = "allow-ssh-from-bastion"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.hub_bastion_subnet
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.workload.name
}

# Peering 검증용: VNet 내부끼리 ICMP 허용 (양 VNet 은 VirtualNetwork 태그에 peering 이 포함되지 않으므로,
# 명시적으로 양측 CIDR 을 허용해야 cross-VNet ping 이 통함)
resource "azurerm_network_security_rule" "allow_icmp_intervnet" {
  name                   = "allow-icmp-intervnet"
  priority               = 110
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Icmp"
  source_port_range      = "*"
  destination_port_range = "*"
  source_address_prefixes = [
    var.hub_address_space,
    var.spoke_address_space,
  ]
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.workload.name
}

# ASG 대상 HTTP(80/TCP) — 실제로 웹 서버는 안 깔지만, ASG·NSG·피어링 경로 테스트에 활용 (curl 실패 vs 성공).
resource "azurerm_network_security_rule" "allow_http_to_app_asg" {
  name                   = "allow-http-to-app-asg"
  priority               = 120
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "80"
  source_address_prefixes = [
    var.hub_address_space,
    var.spoke_address_space,
  ]
  destination_application_security_group_ids = [azurerm_application_security_group.app.id]
  resource_group_name                        = data.azurerm_resource_group.this.name
  network_security_group_name                = azurerm_network_security_group.workload.name
}

resource "azurerm_subnet_network_security_group_association" "hub_workload" {
  subnet_id                 = azurerm_subnet.hub_workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_workload" {
  subnet_id                 = azurerm_subnet.spoke_workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}
