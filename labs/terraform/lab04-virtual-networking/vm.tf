locals {
  ubuntu_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# --- Hub VM -------------------------------------------------------------

resource "azurerm_network_interface" "hub_vm" {
  name                = "nic-vm-hub"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hub_workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_security_group_association" "hub_vm" {
  network_interface_id          = azurerm_network_interface.hub_vm.id
  application_security_group_id = azurerm_application_security_group.app.id
}

resource "azurerm_linux_virtual_machine" "hub" {
  name                = "vm-hub"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  size                = var.vm_size
  tags                = local.tags

  admin_username                  = var.admin_username
  admin_password                  = random_password.vm.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.hub_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = local.ubuntu_image.publisher
    offer     = local.ubuntu_image.offer
    sku       = local.ubuntu_image.sku
    version   = local.ubuntu_image.version
  }
}

# --- Spoke VM -----------------------------------------------------------

resource "azurerm_network_interface" "spoke_vm" {
  name                = "nic-vm-spoke"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke_workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_security_group_association" "spoke_vm" {
  network_interface_id          = azurerm_network_interface.spoke_vm.id
  application_security_group_id = azurerm_application_security_group.app.id
}

resource "azurerm_linux_virtual_machine" "spoke" {
  name                = "vm-spoke"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  size                = var.vm_size
  tags                = local.tags

  admin_username                  = var.admin_username
  admin_password                  = random_password.vm.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.spoke_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = local.ubuntu_image.publisher
    offer     = local.ubuntu_image.offer
    sku       = local.ubuntu_image.sku
    version   = local.ubuntu_image.version
  }
}
