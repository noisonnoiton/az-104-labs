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

output "blob_container_name" {
  value = azurerm_storage_container.blob.name
}

output "file_share_name" {
  value = azurerm_storage_share.files.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_file_endpoint" {
  value = azurerm_storage_account.this.primary_file_endpoint
}

output "primary_access_key" {
  description = "Storage Account primary key. `terraform output -raw primary_access_key` 로 조회."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "subnet_name" {
  value = azurerm_subnet.storage.name
}
