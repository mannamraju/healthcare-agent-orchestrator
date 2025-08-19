output "workspace_id" {
  description = "The ID of the Healthcare Workspace"
  value       = azurerm_healthcare_workspace.healthcare_workspace.id
}

output "fhir_service_id" {
  description = "The ID of the FHIR Service"
  value       = azurerm_healthcare_fhir_service.fhir_service.id
}

output "endpoint" {
  description = "The FHIR service endpoint"
  value       = "https://${azurerm_healthcare_fhir_service.fhir_service.name}.fhir.azurehealthcareapis.com"
}
