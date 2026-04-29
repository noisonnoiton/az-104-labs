# 할당된 Resource Group 이 존재하고, Contributor 로 읽을 수 있는지 검증합니다.
# 이후 Lab 모듈(VNet, Storage 등)은 여기에 이어서 추가합니다.

data "azurerm_resource_group" "student" {
  name = var.resource_group_name
}

output "resource_group_name" {
  description = "확인된 Resource Group 이름"
  value       = data.azurerm_resource_group.student.name
}

output "resource_group_id" {
  description = "Resource Group 리소스 ID"
  value       = data.azurerm_resource_group.student.id
}

output "resource_group_location" {
  description = "리전"
  value       = data.azurerm_resource_group.student.location
}
