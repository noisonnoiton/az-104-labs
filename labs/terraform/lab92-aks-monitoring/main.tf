data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  location = var.location != "" ? var.location : data.azurerm_resource_group.this.location
  tags     = var.tags
}

# --- Log Analytics Workspace -------------------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  sku                 = var.log_analytics_sku
  retention_in_days   = var.retention_in_days
  tags                = local.tags
}

# --- Application Insights (workspace-based) -----------------------------------

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "other"
  tags                = local.tags
}
