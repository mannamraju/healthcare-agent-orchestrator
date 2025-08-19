# Required providers for the AI Services Module

terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}
