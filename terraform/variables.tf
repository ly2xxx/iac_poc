# Variables for Proxmox provider configuration
# Store sensitive values in terraform.tfvars (not committed to git)

variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.local:8006/api2/json)"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox username (e.g., terraform@pve)"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (useful for self-signed certificates)"
  type        = bool
  default     = true
}

variable "target_node" {
  description = "Proxmox node name where VMs will be created"
  type        = string
  default     = "pve"
}
