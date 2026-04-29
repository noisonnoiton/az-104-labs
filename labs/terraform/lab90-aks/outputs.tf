output "resource_group_name" {
  description = "사용한 Resource Group 이름."
  value       = data.azurerm_resource_group.this.name
}

output "location" {
  description = "리소스가 생성된 Azure region."
  value       = local.location
}

output "aks_cluster_name" {
  description = "AKS 클러스터 이름."
  value       = azurerm_kubernetes_cluster.this.name
}

output "aks_fqdn" {
  description = "AKS API 서버 FQDN."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "kube_config_command" {
  description = "kubeconfig 가져오기 명령."
  value       = "az aks get-credentials -g ${data.azurerm_resource_group.this.name} -n ${azurerm_kubernetes_cluster.this.name} --overwrite-existing"
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "aks_subnet_name" {
  value = azurerm_subnet.aks.name
}

output "acr_name" {
  description = "연결된 공유 ACR 이름."
  value       = data.azurerm_container_registry.shared.name
}

output "acr_login_server" {
  description = "ACR 로그인 서버."
  value       = data.azurerm_container_registry.shared.login_server
}
