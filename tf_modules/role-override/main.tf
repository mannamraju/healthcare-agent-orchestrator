# Role Override Module
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

variable "create_role_assignments" {
  description = "Whether to create role assignments or not"
  type        = bool
  default     = true
}

output "create_role_assignments" {
  description = "Whether to create role assignments or not"
  value       = var.create_role_assignments
}
