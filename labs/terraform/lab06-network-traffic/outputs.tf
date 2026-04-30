# --- Network ---

output "vnet_name" {
  description = "VNet 이름"
  value       = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  description = "Resource Group 이름"
  value       = data.azurerm_resource_group.this.name
}

output "location" {
  description = "배포 리전"
  value       = local.location
}

# --- VM ---

output "vm_public_ips" {
  description = "각 VM의 Public IP 주소"
  value       = azurerm_public_ip.vm[*].ip_address
}

output "vm_admin_username" {
  description = "VM admin 사용자명"
  value       = var.admin_username
}

output "vm_admin_password" {
  description = "VM admin 비밀번호"
  value       = random_password.vm.result
  sensitive   = true
}

# --- Load Balancer ---

output "lb_public_ip" {
  description = "Load Balancer Frontend Public IP"
  value       = azurerm_public_ip.lb.ip_address
}

output "lb_url" {
  description = "Load Balancer URL (HTTP)"
  value       = "http://${azurerm_public_ip.lb.ip_address}/"
}

# --- Application Gateway ---

output "appgw_public_ip" {
  description = "Application Gateway Frontend Public IP"
  value       = azurerm_public_ip.appgw.ip_address
}

output "appgw_url" {
  description = "Application Gateway URL (HTTP)"
  value       = "http://${azurerm_public_ip.appgw.ip_address}/"
}

output "appgw_image_url" {
  description = "Application Gateway /image/ 경로"
  value       = "http://${azurerm_public_ip.appgw.ip_address}/image/"
}

output "appgw_video_url" {
  description = "Application Gateway /video/ 경로"
  value       = "http://${azurerm_public_ip.appgw.ip_address}/video/"
}
