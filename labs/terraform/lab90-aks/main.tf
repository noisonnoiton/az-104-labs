data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  location = var.location != "" ? var.location : data.azurerm_resource_group.this.location
  tags     = merge(var.tags, { resource_group = var.resource_group_name })
}
