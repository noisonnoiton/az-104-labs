# --- Public IP (Application Gateway) -----------------------------------------

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# --- Application Gateway -----------------------------------------------------

resource "azurerm_application_gateway" "this" {
  name                = "appgw-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  tags                = local.tags

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gw-ipconfig"
    subnet_id = azurerm_subnet.appgw.id
  }

  # --- Frontend ---------------------------------------------------------------

  frontend_ip_configuration {
    name                 = "fe-appgw"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  # --- Backend Pools ----------------------------------------------------------

  backend_address_pool {
    name = "be-default"
  }

  backend_address_pool {
    name = "be-image"
  }

  backend_address_pool {
    name = "be-video"
  }

  # --- Backend HTTP Settings --------------------------------------------------

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  # --- HTTP Listener ----------------------------------------------------------

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "fe-appgw"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  # --- URL Path Map (path-based routing) --------------------------------------

  url_path_map {
    name                               = "path-map"
    default_backend_address_pool_name  = "be-default"
    default_backend_http_settings_name = "http-settings"

    path_rule {
      name                       = "image-rule"
      paths                      = ["/image/*"]
      backend_address_pool_name  = "be-image"
      backend_http_settings_name = "http-settings"
    }

    path_rule {
      name                       = "video-rule"
      paths                      = ["/video/*"]
      backend_address_pool_name  = "be-video"
      backend_http_settings_name = "http-settings"
    }
  }

  # --- Request Routing Rule ---------------------------------------------------

  request_routing_rule {
    name               = "rule-path-based"
    priority           = 10
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-http"
    url_path_map_name  = "path-map"
  }
}

# --- Backend Pool Associations ------------------------------------------------
# Default pool: 모든 VM
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "default" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.vm[count.index].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = tolist(azurerm_application_gateway.this.backend_address_pool)[index(azurerm_application_gateway.this.backend_address_pool.*.name, "be-default")].id
}

# Image pool: vm-0 only
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "image" {
  network_interface_id    = azurerm_network_interface.vm[0].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = tolist(azurerm_application_gateway.this.backend_address_pool)[index(azurerm_application_gateway.this.backend_address_pool.*.name, "be-image")].id
}

# Video pool: vm-1 only
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "video" {
  network_interface_id    = azurerm_network_interface.vm[1].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = tolist(azurerm_application_gateway.this.backend_address_pool)[index(azurerm_application_gateway.this.backend_address_pool.*.name, "be-video")].id
}
