output "resource_group_name" {
  description = "Resource Group 이름"
  value       = data.azurerm_resource_group.this.name
}

output "location" {
  description = "배포 리전"
  value       = local.location
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace 이름"
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "application_insights_name" {
  description = "Application Insights 이름"
  value       = azurerm_application_insights.this.name
}

output "application_insights_connection_string" {
  description = "Application Insights Connection String (OTel Collector에 주입)"
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Application Insights Instrumentation Key (legacy)"
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}
