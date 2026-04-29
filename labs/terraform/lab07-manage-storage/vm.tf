# ── NSG (SSH only) ────────────────────────────────────────────────
resource "azurerm_network_security_group" "vm" {
  name                = "nsg-vm-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

# ── Public IP ─────────────────────────────────────────────────────
resource "azurerm_public_ip" "vm" {
  name                = "pip-vm-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# ── NIC ───────────────────────────────────────────────────────────
resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

# ── VM (Ubuntu 24.04 LTS) ────────────────────────────────────────
resource "azurerm_linux_virtual_machine" "this" {
  name                = "vm-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  size                = var.vm_size
  tags                = local.tags

  admin_username                  = var.admin_username
  admin_password                  = random_password.vm.result
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.vm.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

resource "random_password" "vm" {
  length  = 16
  special = true
}
