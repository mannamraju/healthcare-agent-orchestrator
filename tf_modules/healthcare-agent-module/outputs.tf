output "healthcare_agent_id" {
  description = "The ID of the Healthcare Agent Service Account"
  value       = azurerm_cognitive_account.healthcare_agent.id
}

output "healthcare_agent_name" {
  description = "The name of the Healthcare Agent Service Account"
  value       = azurerm_cognitive_account.healthcare_agent.name
}

output "healthcare_agent_endpoint" {
  description = "The endpoint of the Healthcare Agent Service"
  value       = azurerm_cognitive_account.healthcare_agent.endpoint
}

output "healthcare_agent_principal_id" {
  description = "The principal ID of the Healthcare Agent Service's managed identity"
  value       = azurerm_cognitive_account.healthcare_agent.identity[0].principal_id
}

output "endpoints" {
  description = "Array of Healthcare Agent Service endpoints"
  value       = [azurerm_cognitive_account.healthcare_agent.endpoint]
}

output "healthcare_bots" {
  description = "Map of registered healthcare bots"
  value       = {
    for k, v in var.healthcare_bots : k => {
      name = v.name
    }
  }
}
