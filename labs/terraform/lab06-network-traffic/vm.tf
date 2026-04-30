locals {
  ubuntu_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # VM별 Custom Script — nginx 설치 + 커스텀 페이지
  vm_custom_data = [
    for i in range(var.vm_count) : base64encode(<<-EOF
      #!/bin/bash
      apt-get update -y
      apt-get install -y nginx
      mkdir -p /var/www/html/image /var/www/html/video
      echo "<h1>Hello from vm-${i} (${var.prefix})</h1><p>Backend VM ${i}</p>" > /var/www/html/index.html
      echo "<h1>Image Server — vm-${i}</h1><p>Serving images from vm-${i}</p>" > /var/www/html/image/index.html
      echo "<h1>Video Server — vm-${i}</h1><p>Serving videos from vm-${i}</p>" > /var/www/html/video/index.html
      systemctl enable nginx
      systemctl restart nginx
    EOF
    )
  ]
}

# --- Public IPs (VM 직접 접속용) -----------------------------------------------

resource "azurerm_public_ip" "vm" {
  count               = var.vm_count
  name                = "pip-vm${count.index}-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# --- NICs --------------------------------------------------------------------

resource "azurerm_network_interface" "vm" {
  count               = var.vm_count
  name                = "nic-vm${count.index}-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[count.index].id
  }
}

# --- Linux VMs ---------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "vm${count.index}-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  size                = var.vm_size
  tags                = local.tags

  admin_username                  = var.admin_username
  admin_password                  = random_password.vm.result
  disable_password_authentication = false

  custom_data = local.vm_custom_data[count.index]

  network_interface_ids = [
    azurerm_network_interface.vm[count.index].id,
  ]

  os_disk {
    name                 = "osdisk-vm${count.index}-${var.prefix}"
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
