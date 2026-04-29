data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  location       = var.location != "" ? var.location : data.azurerm_resource_group.this.location
  tags           = var.tags
  storage_prefix = replace(var.prefix, "-", "")
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
