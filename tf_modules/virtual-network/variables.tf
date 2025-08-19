# Virtual Network Module Variables
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "default"
}

variable "location" {
  description = "Azure region for the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "tags" {
  description = "Tags to apply to the virtual network resources"
  type        = map(string)
  default     = {}
}
