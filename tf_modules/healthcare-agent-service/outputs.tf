# Outputs for Healthcare Agent deployment

output "healthcare_agent_id" {
  description = "The ID of the Healthcare Agent Service Account"
  value       = module.healthcare_agent.healthcare_agent_id
}

output "healthcare_agent_name" {
  description = "The name of the Healthcare Agent Service Account"
  value       = module.healthcare_agent.healthcare_agent_name
}

output "healthcare_agent_endpoint" {
  description = "The endpoint of the Healthcare Agent Service"
  value       = module.healthcare_agent.healthcare_agent_endpoint
}

output "healthcare_agent_principal_id" {
  description = "The principal ID of the Healthcare Agent Service's managed identity"
  value       = module.healthcare_agent.healthcare_agent_principal_id
}

output "healthcare_bots" {
  description = "Map of created healthcare bots with their IDs"
  value       = module.healthcare_agent.healthcare_bots
}
