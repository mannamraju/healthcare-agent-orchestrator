output "instrumentation_key" {
  description = "The instrumentation key for the Application Insights instance"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "app_id" {
  description = "The App ID for the Application Insights instance"
  value       = azurerm_application_insights.app_insights.app_id
}

output "connection_string" {
  description = "The connection string for the Application Insights instance"
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}
