locals {
  ubuntu_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# --- Public IP ---------------------------------------------------------------

resource "azurerm_public_ip" "vm" {
  name                = "pip-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = local.zone != null ? [local.zone] : []
  tags                = local.tags
}

# --- NIC ---------------------------------------------------------------------

resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

# --- Linux VM ----------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "this" {
  name                = "vm-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  size                = var.vm_size
  zone                = local.zone
  tags                = local.tags

  admin_username                  = var.admin_username
  admin_password                  = random_password.vm.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  os_disk {
    name                 = "osdisk-${var.prefix}"
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

# --- Data Disk ---------------------------------------------------------------

resource "azurerm_managed_disk" "data" {
  name                 = "disk-data-${var.prefix}"
  resource_group_name  = data.azurerm_resource_group.this.name
  location             = local.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  zone                 = local.zone
  tags                 = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  managed_disk_id    = azurerm_managed_disk.data.id
  virtual_machine_id = azurerm_linux_virtual_machine.this.id
  lun                = 0
  caching            = "None"
}

# --- Custom Script Extension -------------------------------------------------

resource "azurerm_virtual_machine_extension" "setup" {
  name                 = "setup"
  virtual_machine_id   = azurerm_linux_virtual_machine.this.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = jsonencode({
    script = base64encode(file("${path.module}/scripts/setup.sh"))
  })

  tags = local.tags

  depends_on = [azurerm_virtual_machine_data_disk_attachment.data]
}
