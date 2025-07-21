# Networking module for creating VLANs and network configurations
# Based on VirtualizationHowTo article patterns

variable "network_name" {
  description = "Name of the network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID for network isolation"
  type        = number
  default     = null
}

variable "gateway" {
  description = "Gateway IP address"
  type        = string
  default     = null
}

# Note: Proxmox networking is typically configured at the host level
# This module provides a structure for network-related variables
# that can be used by compute resources

output "network_name" {
  description = "The network name"
  value       = var.network_name
}

output "subnet_cidr" {
  description = "The subnet CIDR"
  value       = var.subnet_cidr
}

output "vlan_id" {
  description = "The VLAN ID"
  value       = var.vlan_id
}

output "network_config" {
  description = "Network configuration object"
  value = {
    name       = var.network_name
    cidr       = var.subnet_cidr
    vlan_id    = var.vlan_id
    gateway    = var.gateway
  }
}
