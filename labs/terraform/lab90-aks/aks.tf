# ---------- 공유 ACR 참조 ----------
data "azurerm_container_registry" "shared" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

# ---------- AKS 클러스터 ----------
resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
  dns_prefix          = var.prefix
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "rg-mc-${var.prefix}"
  tags                = local.tags

  # System node pool
  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.vm_size
    vnet_subnet_id      = azurerm_subnet.aks.id
    os_disk_size_gb     = 30
    temporary_name_for_rotation = "tmpsys"
    tags                = local.tags
  }

  # Azure CNI Overlay — 노드 서브넷 IP 절약, Pod에 overlay 네트워크 사용
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    service_cidr        = "172.16.0.0/16"
    dns_service_ip      = "172.16.0.10"
    pod_cidr            = "192.168.0.0/16"
  }

  identity {
    type = "SystemAssigned"
  }
}

# ---------- User node pool ----------
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.vm_size
  node_count            = var.user_node_count
  vnet_subnet_id        = azurerm_subnet.aks.id
  os_disk_size_gb       = 30
  tags                  = local.tags
}

# ---------- ACR attach (AcrPull role) ----------
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = data.azurerm_container_registry.shared.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
