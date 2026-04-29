output "resource_group_name" {
  description = "사용한 Resource Group 이름."
  value       = data.azurerm_resource_group.this.name
}

output "location" {
  description = "리소스가 생성된 Azure region."
  value       = local.location
}

output "vnet_hub_name" {
  value = azurerm_virtual_network.hub.name
}

output "vnet_spoke_name" {
  value = azurerm_virtual_network.spoke.name
}

output "bastion_name" {
  description = "Azure Portal → Bastion 으로 접속할 때 사용."
  value       = azurerm_bastion_host.this.name
}

output "private_dns_zone" {
  value = azurerm_private_dns_zone.internal.name
}

output "nsg_hub_name" {
  description = "Hub workload NSG 이름."
  value       = azurerm_network_security_group.hub_workload.name
}

output "nsg_spoke_name" {
  description = "Spoke workload NSG 이름."
  value       = azurerm_network_security_group.spoke_workload.name
}

output "hub_vm_private_ip" {
  value = azurerm_network_interface.hub_vm.private_ip_address
}

output "spoke_vm_private_ip" {
  value = azurerm_network_interface.spoke_vm.private_ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  description = "VM admin password. `terraform output -raw admin_password` 로 평문 조회."
  value       = random_password.vm.result
  sensitive   = true
}
