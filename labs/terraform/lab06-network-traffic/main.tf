data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  location = var.location != "" ? var.location : data.azurerm_resource_group.this.location
  tags     = var.tags
}

resource "random_password" "vm" {
  length      = 24
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1

  override_special = "!@#-_="
}
