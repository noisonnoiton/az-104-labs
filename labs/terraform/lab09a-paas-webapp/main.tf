data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_container_registry" "shared" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

# App Service 이름은 Azure 전역에서 고유해야 하므로 random suffix 사용
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  location    = var.location != "" ? var.location : data.azurerm_resource_group.this.location
  name_suffix = random_string.suffix.result
}

# ---------- App Service Plan (Linux) ----------
resource "azurerm_service_plan" "this" {
  name                = "${var.prefix}-plan"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  os_type             = "Linux"
  sku_name            = var.sku_name
}

# ---------- Web App for Containers ----------
resource "azurerm_linux_web_app" "this" {
  name                = "${var.prefix}-${local.name_suffix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    container_registry_use_managed_identity = true

    application_stack {
      docker_registry_url = "https://${data.azurerm_container_registry.shared.login_server}"
      docker_image_name   = var.container_image
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITES_PORT                       = "8090"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
}

# ---------- Role Assignment: Web App → ACR Pull ----------
# resource "azurerm_role_assignment" "webapp_acr_pull" {
#   scope                = data.azurerm_container_registry.shared.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
# }
