// Application Insights Module for Healthcare Agent Orchestrator
// Provides monitoring and telemetry for the application

resource "azurerm_application_insights" "app_insights" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  # Commenting out workspace_id as it can't be removed once set
  # workspace_id        = var.log_analytics_workspace_id
  retention_in_days   = 90
  tags                = var.tags
  
  lifecycle {
    ignore_changes = [
      workspace_id
    ]
  }
}

# Role assignments for all service principals
resource "azurerm_role_assignment" "app_insights_data_contributors" {
  count                = length(var.service_principal_ids)
  scope                = azurerm_application_insights.app_insights.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = var.service_principal_ids[count.index]
}

# Role assignment for current user
resource "azurerm_role_assignment" "user_app_insights" {
  count                = var.user_principal_id != "" ? 1 : 0
  scope                = azurerm_application_insights.app_insights.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = var.user_principal_id
}
