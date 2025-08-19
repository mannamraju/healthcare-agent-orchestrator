// FHIR Service Module for Healthcare Agent Orchestrator
// Provides FHIR service for healthcare data integration

resource "azurerm_healthcare_workspace" "healthcare_workspace" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_healthcare_fhir_service" "fhir_service" {
  name                = var.fhir_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_healthcare_workspace.healthcare_workspace.id
  kind                = "fhir-R4"
  
  authentication {
    authority = "https://login.microsoftonline.com/${var.tenant_id}"
    audience  = "https://${var.fhir_service_name}.fhir.azurehealthcareapis.com"
  }

  configuration_export_storage_account_name = var.storage_account_name

  access_policy_object_ids = concat(
    [for contributor in var.data_contributors : contributor.id],
    [for reader in var.data_readers : reader.id]
  )

  tags = var.tags
}
