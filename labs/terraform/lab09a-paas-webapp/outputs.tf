output "resource_group_name" {
  value = data.azurerm_resource_group.this.name
}

output "app_service_plan_name" {
  value = azurerm_service_plan.this.name
}

output "webapp_name" {
  value = azurerm_linux_web_app.this.name
}

output "webapp_url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "webapp_principal_id" {
  value       = azurerm_linux_web_app.this.identity[0].principal_id
  description = "Web App의 System Assigned Managed Identity principal ID"
}
