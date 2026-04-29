resource "azurerm_application_security_group" "app_hub" {
  name                = "asg-${var.prefix}-app-hub"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

resource "azurerm_application_security_group" "app_spoke" {
  name                = "asg-${var.prefix}-app-spoke"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

# -----------------------------------------------------------------------
# Hub NSG: Bastion -> vm-hub SSH 허용
# -----------------------------------------------------------------------
resource "azurerm_network_security_group" "hub_workload" {
  name                = "nsg-${var.prefix}-hub"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

# Hub VM: AzureBastionSubnet 에서 SSH 직접 접속 허용
resource "azurerm_network_security_rule" "hub_allow_ssh_from_bastion" {
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
  network_security_group_name = azurerm_network_security_group.hub_workload.name
}

resource "azurerm_network_security_rule" "hub_allow_icmp" {
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
  network_security_group_name = azurerm_network_security_group.hub_workload.name
}

resource "azurerm_network_security_rule" "hub_allow_http" {
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
  destination_application_security_group_ids = [azurerm_application_security_group.app_hub.id]
  resource_group_name                        = data.azurerm_resource_group.this.name
  network_security_group_name                = azurerm_network_security_group.hub_workload.name
}

# 명시된 규칙 외 모든 인바운드 차단 (AllowVnetInBound 기본 규칙 override)
resource "azurerm_network_security_rule" "hub_deny_all_inbound" {
  name                        = "deny-all-inbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.hub_workload.name
}

# -----------------------------------------------------------------------
# Spoke NSG: vm-hub 에서만 SSH 허용 (Bastion 직접 접속 차단 = 점프 서버 패턴)
# -----------------------------------------------------------------------
resource "azurerm_network_security_group" "spoke_workload" {
  name                = "nsg-${var.prefix}-spoke"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

# Spoke VM: Hub 워크로드 서브넷(= vm-hub)에서만 SSH 허용 — Bastion 직접 차단
resource "azurerm_network_security_rule" "spoke_allow_ssh_from_hub" {
  name                        = "allow-ssh-from-hub"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.hub_workload_subnet
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.spoke_workload.name
}

# Bastion 서브넷 → Spoke SSH 를 명시적으로 차단.
# 이 규칙이 없으면 기본 규칙 AllowVnetInBound(65000)이 허용해버림.
resource "azurerm_network_security_rule" "spoke_deny_ssh_from_bastion" {
  name                        = "deny-ssh-from-bastion"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.hub_bastion_subnet
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.spoke_workload.name
}

resource "azurerm_network_security_rule" "spoke_allow_icmp" {
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
  network_security_group_name = azurerm_network_security_group.spoke_workload.name
}

resource "azurerm_network_security_rule" "spoke_allow_http" {
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
  destination_application_security_group_ids = [azurerm_application_security_group.app_spoke.id]
  resource_group_name                        = data.azurerm_resource_group.this.name
  network_security_group_name                = azurerm_network_security_group.spoke_workload.name
}

# 명시된 규칙 외 모든 인바운드 차단 (AllowVnetInBound 기본 규칙 override)
resource "azurerm_network_security_rule" "spoke_deny_all_inbound" {
  name                        = "deny-all-inbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.spoke_workload.name
}

resource "azurerm_subnet_network_security_group_association" "hub_workload" {
  subnet_id                 = azurerm_subnet.hub_workload.id
  network_security_group_id = azurerm_network_security_group.hub_workload.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_workload" {
  subnet_id                 = azurerm_subnet.spoke_workload.id
  network_security_group_id = azurerm_network_security_group.spoke_workload.id
}
