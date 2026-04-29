output "resource_group_name" {
  description = "사용한 Resource Group 이름."
  value       = data.azurerm_resource_group.this.name
}

output "location" {
  description = "리소스가 생성된 Azure region."
  value       = local.location
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.this.name
}

output "vm_public_ip" {
  description = "SSH 접속용 Public IP."
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_private_ip" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  description = "VM admin password. `terraform output -raw admin_password` 로 평문 조회."
  value       = random_password.vm.result
  sensitive   = true
}

output "data_disk_name" {
  value = azurerm_managed_disk.data.name
}

output "nsg_name" {
  value = azurerm_network_security_group.this.name
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}
