output "id" {
  description = "The ID of the storage account"
  value       = local.storage_account_id
}

output "name" {
  description = "The name of the storage account"
  value       = var.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = local.blob_endpoint
}

output "blob_endpoint" {
  description = "The blob endpoint of the storage account (alias for primary_blob_endpoint)"
  value       = local.blob_endpoint
}

# No connection string - can't use key-based authentication
output "primary_connection_string" {
  description = "The primary connection string"
  value       = "Key-based authentication not available for this storage account"
  sensitive   = true
}

output "chat_artifacts_container_name" {
  description = "Name of the chat artifacts container"
  value       = "chat-artifacts"
}

output "chat_sessions_container_name" {
  description = "Name of the chat sessions container"
  value       = "chat-sessions"
}

output "patient_data_container_name" {
  description = "Name of the patient data container"
  value       = "patient-data"
}
