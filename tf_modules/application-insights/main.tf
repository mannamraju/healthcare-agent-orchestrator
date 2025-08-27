// Application Insights Module for Healthcare Agent Orchestrator
// Provides monitoring and telemetry for the application

resource "azurerm_application_insights" "app_insights" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  local_authentication_disabled = true
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

# Role Definitions (use IDs instead of names to avoid drift)
data "azurerm_role_definition" "monitoring_metrics_publisher" {
  name  = "Monitoring Metrics Publisher"
  scope = "/"
}

data "azurerm_role_definition" "monitoring_contributor" {
  name  = "Monitoring Contributor"
  scope = "/"
}

# Role assignments for all service principals
resource "azurerm_role_assignment" "app_insights_data_contributors" {
  count                = length(var.service_principal_ids)
  scope                = azurerm_application_insights.app_insights.id
  role_definition_id   = data.azurerm_role_definition.monitoring_metrics_publisher.id
  principal_id         = var.service_principal_ids[count.index]
  principal_type       = "ServicePrincipal"
}

# Role assignment for current user
resource "azurerm_role_assignment" "user_app_insights" {
  count                = var.user_principal_id != "" ? 1 : 0
  scope                = azurerm_application_insights.app_insights.id
  role_definition_id   = data.azurerm_role_definition.monitoring_contributor.id
  principal_id         = var.user_principal_id
  principal_type       = "User"
}
