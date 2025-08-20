# Outputs for Healthcare Agent deployment

output "healthcareAgentServiceEndpoints" {
  description = "Array of Healthcare Agent Service endpoints with management portal links"
  value       = module.healthcare_agent.healthcareAgentServiceEndpoints
}

output "healthcare_bots" {
  description = "Map of created healthcare bots with their IDs"
  value       = module.healthcare_agent.healthcare_bots
}

# For backward compatibility
output "healthcare_agent_id" {
  description = "[DEPRECATED] The ID of the first Healthcare Agent Service Account (for backward compatibility)"
  value       = length(module.healthcare_agent.healthcareAgentServiceEndpoints) > 0 ? module.healthcare_agent.healthcareAgentServiceEndpoints[0].id : ""
}

output "healthcare_agent_name" {
  description = "[DEPRECATED] The name of the first Healthcare Agent Service Account (for backward compatibility)"
  value       = length(module.healthcare_agent.healthcareAgentServiceEndpoints) > 0 ? module.healthcare_agent.healthcareAgentServiceEndpoints[0].name : ""
}

output "healthcare_agent_endpoint" {
  description = "[DEPRECATED] The endpoint of the Healthcare Agent Service (for backward compatibility)"
  value       = "" # No direct equivalent in the new implementation
}

output "healthcare_agent_principal_id" {
  description = "[DEPRECATED] The principal ID of the Healthcare Agent Service's managed identity (for backward compatibility)"
  value       = "" # No direct equivalent in the new implementation
}
