# --- Public IP (LB) ----------------------------------------------------------

resource "azurerm_public_ip" "lb" {
  name                = "pip-lb-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# --- Load Balancer -----------------------------------------------------------

resource "azurerm_lb" "this" {
  name                = "lb-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name                 = "fe-lb"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

# --- Backend Pool ------------------------------------------------------------

resource "azurerm_lb_backend_address_pool" "this" {
  name            = "be-pool"
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.vm[count.index].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
}

# --- Health Probe ------------------------------------------------------------

resource "azurerm_lb_probe" "http" {
  name                = "hp-http"
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

# --- LB Rule -----------------------------------------------------------------

resource "azurerm_lb_rule" "http" {
  name                           = "rule-http"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "fe-lb"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
  probe_id                       = azurerm_lb_probe.http.id
  idle_timeout_in_minutes        = 4
  tcp_reset_enabled              = true
}
