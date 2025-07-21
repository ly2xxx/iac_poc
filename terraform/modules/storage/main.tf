# Storage module for managing additional storage resources
# Based on VirtualizationHowTo article patterns

variable "storage_type" {
  description = "Type of storage (fast-ssd, standard, etc.)"
  type        = string
  default     = "standard"
}

variable "size_gb" {
  description = "Size in GB"
  type        = number
  default     = 100
}

variable "vm_ids" {
  description = "List of VM IDs to attach storage to"
  type        = list(number)
  default     = []
}

variable "storage_pool" {
  description = "Storage pool to use"
  type        = string
  default     = "local-zfs"
}

# Note: Additional disk attachment would typically be done
# within the VM resource itself in Proxmox
# This module provides structure for storage-related variables

locals {
  storage_config = {
    type = var.storage_type
    size = var.size_gb
    pool = var.storage_pool
  }
}

output "storage_config" {
  description = "Storage configuration"
  value       = local.storage_config
}

output "storage_type" {
  description = "Storage type"
  value       = var.storage_type
}
