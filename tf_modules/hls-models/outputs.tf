# HLS Models Module Outputs
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

output "model_endpoints" {
  description = "Map of model names to their endpoint URLs"
  value = local.model_endpoints
}
