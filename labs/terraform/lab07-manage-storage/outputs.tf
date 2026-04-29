output "resource_group_name" {
  description = "사용한 Resource Group 이름."
  value       = data.azurerm_resource_group.this.name
}

output "location" {
  description = "리소스가 생성된 Azure region."
  value       = local.location
}

output "storage_account_name" {
  description = "Storage Account 이름 (전역 고유)."
  value       = azurerm_storage_account.this.name
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "web_container_name" {
  value = azurerm_storage_container.web.name
}

output "index_html_url" {
  description = "Public URL for index.html in web container."
  value       = "${azurerm_storage_account.this.primary_blob_endpoint}${azurerm_storage_container.web.name}/${azurerm_storage_blob.index_html.name}"
}

output "network_default_action" {
  description = "Current network rules default action."
  value       = var.network_default_action
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "file_share_name" {
  value = azurerm_storage_share.files.name
}

output "primary_access_key" {
  description = "Storage Account primary key."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "vm_public_ip" {
  description = "VM public IP address for SSH access."
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_admin_username" {
  value = var.admin_username
}

output "vm_admin_password" {
  value     = random_password.vm.result
  sensitive = true
}
